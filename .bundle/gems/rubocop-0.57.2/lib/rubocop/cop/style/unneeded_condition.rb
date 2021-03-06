# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for unnecessary conditional expressions.
      #
      # @example
      #   # bad
      #   a = b ? b : c
      #
      #   # good
      #   a = b || c
      #
      # @example
      #   # bad
      #   if b
      #     b
      #   else
      #     c
      #   end
      #
      #   # good
      #   b || c
      #
      #   # good
      #   if b
      #     b
      #   elsif cond
      #     c
      #   end
      #
      class UnneededCondition < Cop
        include RangeHelp

        MSG = 'Use double pipes `||` instead.'.freeze

        def on_if(node)
          return unless offense?(node)
          add_offense(node, location: range_of_offense(node))
        end

        def autocorrect(node)
          lambda do |corrector|
            if node.ternary?
              corrector.replace(range_of_offense(node), '||')
            else
              corrected = [node.if_branch.source,
                           else_source(node.else_branch)].join(' || ')

              corrector.replace(node.source_range, corrected)
            end
          end
        end

        private

        def range_of_offense(node)
          return :expression unless node.ternary?
          range_between(node.loc.question.begin_pos, node.loc.colon.end_pos)
        end

        def offense?(node)
          return false if node.elsif_conditional?

          condition, if_branch, else_branch = *node

          condition == if_branch && !node.elsif? && (
            node.ternary? ||
            !else_branch.instance_of?(AST::Node) ||
            else_branch.single_line?
          )
        end

        def else_source(else_branch)
          wrap_else = MODIFIER_NODES.include?(else_branch.type) &&
                      else_branch.modifier_form?
          wrap_else ? "(#{else_branch.source})" : else_branch.source
        end
      end
    end
  end
end

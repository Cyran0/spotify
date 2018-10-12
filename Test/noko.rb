require 'rubygems'
require 'nokogiri'
require 'open-uri'

def get_the_email_of_a_townhal_from_its_webpage
    doc = Nokogiri::HTML(open("http://annuaire-des-mairies.com/95/vaureal.html"))
    email = doc.css(".tr-last")[3].text.split(" ")[2]
end
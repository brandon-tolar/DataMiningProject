=begin
Author: btolar1

gets xml of property data using zillow api call
=end

require 'net/http'
require 'nokogiri'
require 'set'

class ZillowProperty
  attr_accessor :data
  
  def initialize(address, city_state_zip)
    @zws_id = "X1-ZWz19dcnto8avf_7x5fi"   #MY Zillow Web Service Identifier
    @address = address
    @city_state_zip = city_state_zip
    @uri_str = "http://www.zillow.com/webservice/GetDeepSearchResults.htm?zws-id=#{@zws_id}&address=#{@address}&citystatezip=#{@city_state_zip}"
    @xml = Nokogiri::XML(Net::HTTP.get(URI(@uri_str)))
    @data = Hash.new
    
    @data = {
      :id => @xml.xpath("//zpid").to_s.gsub!(/<\/?zpid>/,"").to_i,
      :lat => @xml.xpath("//latitude").to_s.gsub!(/<\/?latitude>/,"").to_f,
      :long => @xml.xpath("//longitude").to_s.gsub!(/<\/?longitude>/,"").to_f,
      :tax_assess_year => @xml.xpath("//taxAssessmentYear").to_s.gsub!(/<\/?taxAssessmentYear>/,"").to_i,
      :tax_assessment => @xml.xpath("//taxAssessment").to_s.gsub!(/<\/?taxAssessment>/,"").to_f,
      :year_built => @xml.xpath("//yearBuilt").to_s.gsub!(/<\/?yearBuilt>/,"").to_i,
      :lot_sqft => @xml.xpath("//lotSizeSqFt").to_s.gsub!(/<\/?lotSizeSqFt>/,"").to_i,
      :finished_sqft => @xml.xpath("//finishedSqFt").to_s.gsub!(/<\/?finishedSqFt>/,"").to_i,
      :baths => @xml.xpath("//bathrooms").to_s.gsub!(/<\/?bathrooms>/,"").to_i,
      :beds => @xml.xpath("//bedrooms").to_s.gsub!(/<\/?bedrooms>/,"").to_i,
      :lastSoldDate => @xml.xpath("//lastSoldDate").to_s.gsub!(/<\/?lastSoldDate>/,""),
      :lastSoldPrice => @xml.xpath("//lastSoldPrice").to_s.gsub!(/<\/?lastSoldPrice>/,"").to_f,
      :zestimate => @xml.xpath("///amount").to_s.gsub!(/<\/?amount.*>/,"").to_f
    }
  end
  
  def to_s
    @data.values.to_s[1..-2] #strips square brackets
  end
end

city_state_zip = "Charlotte+NC"
address = "429+Wellingford+St"

#prop = ZillowProperty.new(address, city_state_zip)
#print prop.to_s

num_compare = 5     #number of comparable recent sales to obtain
prop_id = ''   #ID for the property for which to obtain information
zws_id = "X1-ZWz19dcnto8avf_7x5fi"   #MY Zillow Web Service Identifier



all_addresses = Array.new

def get_comps(prop_id)
  uri_str = "http://www.zillow.com/webservice/GetComps.htm?zws-id=#{zws_id}&zpid=#{prop_id}&count=#{num_compare}"
  xml = Nokogiri::XML(Net::HTTP.get(URI(uri_str)))
  new_addresses = xml.xpath("//street").to_s.gsub!(/<\/?street>/,"/").gsub(/ /,'+').split('/').delete_if {|i| i==""}
  search_addresses = Set.new new_addresses
end

#puts "latitude, longitude, taxAssessmentYear, taxAssessment, yearBuilt, lotSizeSqFt, finishedSqFt"
while !search_addresses.empty?
  if count < 50
    current = search_addresses.to_a.remove_at 1
    all_addresses.add current
    
    count++
end

search_addresses.each do |i|
  prop = ZillowProperty.new(i, city_state_zip)
  all_addresses.add i
  puts prop.to_s
end

puts get_comps(prop_id)

#puts all_addresses

require 'nokogiri'
require 'open-uri'
require 'pry'
require 'net/http'
require 'uri'
require 'json'
require 'rest-client'
#require_relative "./lib/api_communicator.rb"

# html = open("https://www.melissadata.com/lookups/GeoCoder.asp?InData=11209&submit=Search")
# doc = Nokogiri::HTML(html)
# lat_long = doc.css(".padd").to_a.map {|x| x.text}[0..1]
# lat = lat_long[0].to_f
# long = lat_long[1].to_f
#
# ###
# uri = URI.parse("https://developers.zomato.com/api/v2.1/geocode?lat=40.624&lon=-74.03")
# request = Net::HTTP::Get.new(uri)
# request["Accept"] = "application/json"
# request["User-Key"] = "d5b63600443f3d619698a2aa133b3b62"
#
# req_options = {
#   use_ssl: uri.scheme == "https",
# }
#
# response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
#   http.request(request)
# end
#
# test = JSON.parse(response.body)["nearby_restaurants"]
#
# hash = {}
# nearby_restaurants = test.map do |x|
#   i = ""
#   x["restaurant"]["price_range"].times do i += "$" end
#   {name: x["restaurant"]["name"],
#     cuisines: x["restaurant"]["cuisines"],
#     price_range: i}
#   end
# ###
#
# def beautify_nearby_restaurants(nearby_restaurants)
#   x = 1
#   nearby_restaurants.each do |restaurant|
#     puts "#{x}. #{restaurant[:name]} -- #{restaurant[:cuisines]} -- #{restaurant[:price_range]}"
#     x += 1
#   end
# end

# uri = URI.parse("https://developers.zomato.com/api/v2.1/search?count=100&lat=40.624&lon=-74.03&radius=8000&sort=real_distance")
# request = Net::HTTP::Get.new(uri)
# request["Accept"] = "application/json"
# request["User-Key"] = "d5b63600443f3d619698a2aa133b3b62"
#
# req_options = {
# use_ssl: uri.scheme == "https",
# }
#
# response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
# http.request(request)
# end
#
# # binding.pry
#
# JSON.parse(response.body)

# binding.pry
# def parse_json_daily_menu#(restaurant_id)
#
#   uri = URI.parse("https://developers.zomato.com/api/v2.1/dailymenu?res_id=16507624")
#   request = Net::HTTP::Get.new(uri)
#   request["Accept"] = "application/json"
#   request["User_key"] = "d5b63600443f3d619698a2aa133b3b62"
#
#   req_options = {
#     use_ssl: uri.scheme == "https",
#   }
#
#   response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
#     http.request(request)
#   end
#   # binding.pry
#   JSON.parse(response.body)
# end
api = RestClient.get("api.zippopotam.us/us/00000"){|response, request, result| response }
if api == "RestClient::Response 404 \"{}\""
  puts "invalid zipcode"
end


# binding.pry
's'

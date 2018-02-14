require 'rest-client'
require 'json'
require 'pry'
require 'nokogiri'
require 'open-uri'
require_relative 'input_checks'

# jason_api_key = "d5b63600443f3d619698a2aa133b3b62"
# john_api_key = "b3bc425599edde972d3b4f3460d82332"

def get_zipcode_from_user
  puts "Please enter your zipcode."
  zipcode = gets.strip
  until zipcode.length == 5 && zipcode.to_i.is_a?(Fixnum) && zipcode.to_i.to_s.length == 5 && check_zipcode(zipcode)
    puts "Please enter a valid 5-digit zipcode."
    zipcode = gets.strip
  end
  zipcode
end

def get_lat(zipcode)
  api = RestClient.get("api.zippopotam.us/us/#{zipcode}")
  lat = JSON.parse(api)["places"][0]["latitude"]
end

def get_long(zipcode)
  api = RestClient.get("api.zippopotam.us/us/#{zipcode}")
  long = JSON.parse(api)["places"][0]["longitude"]
end

def parse_json_geocode(lat, long)
  uri = URI.parse("https://developers.zomato.com/api/v2.1/search?count=100&lat=#{lat}&lon=#{long}&radius=8000&sort=real_distance")
  request = Net::HTTP::Get.new(uri)
  request["Accept"] = "application/json"
  request["User-Key"] = "b3bc425599edde972d3b4f3460d82332"

  req_options = {
    use_ssl: uri.scheme == "https",
  }

  response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
    http.request(request)
  end
  JSON.parse(response.body)["restaurants"].reverse
end

def nearby_restaurants_hash(parse_data)
  parse_data.map do |x|
    {name: x["restaurant"]["name"],
    cuisines: x["restaurant"]["cuisines"],
    price_range: "$" * x["restaurant"]["price_range"],
    zipcode: x["restaurant"]["location"]["zipcode"],
    address: x["restaurant"]["location"]["address"]}
  end
end

def beautify_nearby_restaurants(nearby_restaurants)
  puts "These restaurants are nearby."
  x = 1
  beautified = nearby_restaurants.each do |restaurant|
    puts "#{x}. #{restaurant[:name]} -- #{restaurant[:cuisines]} -- #{restaurant[:price_range]}"
    x += 1
  end
  beautified
end

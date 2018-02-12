require_relative 'config/environment'

#!/usr/bin/env ruby

require_relative "../lib/api_communicator.rb"
require 'pry'

welcome
zipcode = get_zipcode_from_user
lat = get_lat(zipcode)
long = get_long(zipcode)
geocode_data = parse_json_geocode(lat, long)
nearby_restaurants = get_nearby_restaurants(geocode_data)
beautified = beautify_nearby_restaurants(nearby_restaurants)
user = get_restaurant_from_user(nearby_restaurants)
binding.pry

# restaurant = get_restaurant_from_user
'hi'

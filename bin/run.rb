#!/usr/bin/env ruby
require_relative '../config/environment'
require_relative "../lib/welcome.rb"

# require_relative "../lib/yelp.rb"
#require_relative class files

require 'pry'

welcome


# # 1. sign in to view your Reservations
#
# # 2. make a reservation
#
# # user enters zip code to search restaurants
# zipcode = get_zipcode_from_user
#
# # take zipcode to get latitude coordinate
# lat = get_lat(zipcode)
#
# # take zipcode to get longitude coordinate
# long = get_long(zipcode)
#
# # plug lat and long into Zomato API. Parse the data for nearby restaurants
# nearby_restaurants = parse_json_geocode(lat, long)
#
# # extract information we want from parsed data. :name, :cuisines, :price_range, :zipcode
# nearby_restaurants_neat = nearby_restaurants_hash(nearby_restaurants)
#
# # puts condensed information for user to seleect restaurant
# beautified = beautify_nearby_restaurants(nearby_restaurants_neat)
# # binding.pry
# # user selects a restaurant to reserve a table
# user_choice = get_restaurant_from_user(nearby_restaurants_neat)
#
# # finds the user's selected restaurant from parsed data
# restaurant_hash = beautified[user_choice.to_i]
#
# customer_sign_in(restaurant_hash)
# # binding.pry
#
# # ask customer for their :username
# # if no username ask to create account
# #   new account has :username, :password, :fullname, :phone_number
# # else ask cstomer for their :password
#
#
#
# # ask customer for information to create reservation. :reservation_date, :reservation_time, :party_size, :customer, :restaurant, :cancelled = default.false
#
#
# # add the restaurant to db
#
# # confirm reservation with Reservation.id
#
#
#
#
# ### INSTANCE METHODS
#
# # customer can cancel reservation
# # customer can modify reservation (date, time, size)
# # customer can view reservations
# # customer can view reservations by date
#
# # restaurant can view reservations
# # restairamt cam view reservations by date
#
# # resevation.all
#
# # binding.pry
#
#
# # binding.pry
#
# # restaurant = get_restaurant_from_user
'hi'

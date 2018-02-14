require 'rest-client'
require 'json'
require 'pry'
require 'nokogiri'
require 'open-uri'

require_relative 'input_checks.rb'
require_relative 'api_location_methods'


def make_reservation
  zipcode = get_zipcode_from_user
  lat = get_lat(zipcode)
  long = get_long(zipcode)
  nearby_restaurants = parse_json_geocode(lat, long)
  nearby_restaurants_neat = nearby_restaurants_hash(nearby_restaurants)
  beautified = beautify_nearby_restaurants(nearby_restaurants_neat)
  user_choice = get_restaurant_from_user(nearby_restaurants_neat)
  restaurant_hash = beautified[user_choice.to_i]
  customer_sign_in(restaurant_hash)
  welcome
end

def get_restaurant_from_user(nearby_restaurants_neat)
  puts "Please select a restaurant to reserve a table at. (enter a number)"
  input = gets.strip
  until check_input_is_only_number(input) && input.to_i > 0 && input.to_i <= nearby_restaurants_neat.length
    invalid_input(nearby_restaurants_neat)
    input = gets.strip
  end
  input.to_i - 1
end

def customer_sign_in(restaurant_hash)
  puts "Please sign in"
  puts "enter username"
  username = gets.strip
  customer = Customer.find_by(username: username)
  # username exists
  if customer
    reservation_details = customer_exist(customer)
    reservation_confirm(reservation_details, restaurant_hash, customer)
  else
    customer = customer_create
    reservation_details = get_reservation_details
    # binding.
    reservation_confirm(reservation_details, restaurant_hash, customer)
  end
end

def reservation_confirm(reservation_details, restaurant_hash, customer)
  puts "confirm reservation? y/n?"
  answer = gets.strip.downcase
  until answer == "y" || answer =="yes" || answer == "n" || answer == "no"
    puts "confirm reservation? y/n?"
    answer = gets.strip.downcase
  end
  if answer == "y" || answer == "yes"
    restaurant = restaurant_exist?(restaurant_hash)
    if same_day_and_time_reservation?(reservation_details, customer)
      puts "You already have a reservation for that day and time"
    elsif restaurant
      reservation = create_reservation(reservation_details, customer, restaurant)
      puts "Your reservation for #{reservation_details[:party_size]} at #{restaurant[:name]} on #{reservation_details[:date]} @ #{time_format(reservation_details[:time].to_s)} has been confirmed! Your reservation id is #{reservation.id}"
    else
      restaurant = Restaurant.create(restaurant_hash)
      reservation = create_reservation(reservation_details, customer, restaurant)
      puts "Your reservation for #{reservation_details[:party_size]} at #{restaurant[:name]} on #{reservation_details[:date]} @ #{time_format(reservation_details[:time].to_s)} has been confirmed! Your reservation id is #{reservation.id}"
    end
  elsif answer == "n" || answer == "no"
    goodbye
    exit
  end
end

def restaurant_exist?(restaurant_hash)
  restaurant = Restaurant.find_by(name: restaurant_hash[:name], cuisines: restaurant_hash[:cuisines], zipcode: restaurant_hash[:zipcode], address: restaurant_hash[:address])
end

def create_reservation(reservation_details, customer, restaurant)
  reservation = Reservation.new(reservation_details)
  reservation[:customer_id] = customer.id
  reservation[:restaurant_id] = restaurant.id
  reservation.save
  reservation
end
##################################################################
##################################################################

def customer_exist(customer)
  get_password(customer)
  get_reservation_details
end

def get_password(customer)
  puts "enter password"
  password = gets.strip
  until customer.authenticate(password)
    puts "incorrect password"
    puts "enter password"
    password = gets.strip
  end
end

def get_reservation_details
  #party_size
  puts "enter party size"
  party_size = gets.strip
  until valid_party_size?(party_size)
    puts "Please enter a number (min 1, max 10)"
    party_size = gets.strip
  end
  #date
  puts "choose reservation date (dd/mm/yyyy)"
  res_date = gets.strip
  until valid_reservation_date?(res_date)
    puts "Invalid date, please enter a date with the format dd/mm/yyyy"
    res_date = gets.strip
  end
  #time
  if res_date.to_date == Date.today
    puts "These times are available. Please choose reservation time (hhmm)"
    puts available_times.join(", ")
    res_time = gets.strip.to_i
    until valid_same_day_time?(res_time)
      puts "These times are available. Please choose reservation time (hhmm)"
      puts available_times.join(", ")
      res_time = gets.strip.to_i
    end
  else
    puts "These times are available. Please select one of these times."
    puts all_times.join(", ")
    res_time = gets.strip.to_i
    until valid_reservation_time?(res_time)
      puts "These times are available. Please select one of these times."
      puts all_times.join(", ")
      res_time = gets.strip.to_i
    end
  end
  hash = {}
  hash[:date] = res_date
  hash[:time] = res_time
  hash[:party_size] = party_size
  hash
end

##################################################################
##################################################################

def customer_create
  customer_hash = customer_sign_up
  customer = customer_create_password(customer_hash)
end

def customer_sign_up
  hash = {}
  puts "username not found. sign up? y/n?"
  answer = gets.strip.downcase
  until answer == "y" || answer =="yes" || answer == "n" || answer == "no"
    puts "sign up? y/n?"
    answer = gets.strip.downcase
  end
  if answer == "y" || answer =="yes"
    #username
    puts "enter a username between 6 and 16 characters"
    username = gets.strip.downcase
    until valid_username?(username)
      username = gets.strip.downcase
    end
    #name
    puts "enter full name"
    fullname = gets.strip
    puts "enter phone number xxx-xxx-xxxx"
    phone_number = gets.strip
    until valid_phone_number?(phone_number)
      puts "Please enter a valid phone number (xxx-xxx-xxxx)"
      phone_number = gets.strip
    end
    #password
    puts "enter a password between 8 and 16 characters"
    password = gets.strip
    until valid_password?(password)
      puts "enter a password between 8 and 16 characters"
      password = gets.strip
    end
    #confirm
    puts "confirm password"
    confirm = gets.strip
    until password == confirm
      puts "password did not match"
      puts "confirm password"
      confirm = gets.strip
    end
    puts "username created!"
    hash[:username] = username
    hash[:password] = password
    hash[:password_confirmation] = confirm
    hash[:fullname] = fullname
    hash[:phone_number] = phone_number
  else # answer == "n" || answer == "no"
    goodbye
    exit
  end
  hash
end

def customer_create_password(customer_hash)
  customer = Customer.new(customer_hash)
  customer.save
  customer
end

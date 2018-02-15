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
  puts
  puts "Please select a restaurant to reserve a table at. (enter a number)"
  input = gets.strip
  puts
  until check_input_is_only_number(input) && input.to_i > 0 && input.to_i <= nearby_restaurants_neat.length
    invalid_input(nearby_restaurants_neat)
    input = gets.strip
    puts
  end
  input.to_i - 1
end

def customer_sign_in(restaurant_hash)
  puts "Please sign in."
  puts "Enter username."
  username = gets.strip
  puts
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
  puts "Confirm reservation? y/n?"
  answer = gets.strip.downcase
  puts
  until answer == "y" || answer =="yes" || answer == "n" || answer == "no"
    puts "Confirm reservation? y/n?"
    answer = gets.strip.downcase
    puts
  end
  if answer == "y" || answer == "yes"
    restaurant = restaurant_exist?(restaurant_hash)
    if same_day_and_time_reservation?(reservation_details, customer)
      puts "You already have a reservation for that date and time."
      puts
    elsif restaurant
      reservation = create_reservation(reservation_details, customer, restaurant)
      puts "🎉🎊 Congrats! 🎊🎉 Your reservation for #{reservation_details[:party_size]} at #{restaurant[:name]} on #{reservation_details[:date]} @ #{time_format(reservation_details[:time].to_s)} has been confirmed! Your confirmation # is #{reservation.id}."
      puts
    else
      restaurant = Restaurant.create(restaurant_hash)
      reservation = create_reservation(reservation_details, customer, restaurant)
      puts "🎉🎊 Congrats! 🎊🎉 Your reservation for #{reservation_details[:party_size]} at #{restaurant[:name]} on #{reservation_details[:date]} @ #{time_format(reservation_details[:time].to_s)} has been confirmed! Your confirmaton # is #{reservation.id}."
      puts
    end
  elsif answer == "n" || answer == "no"
    puts
    welcome
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
  puts
  get_reservation_details
end

def get_password(customer)
  puts "Enter password."
  password = gets.strip
  puts
  until customer.authenticate(password)
    puts "Incorrect password."
    puts "Enter password."
    password = gets.strip
    puts
  end
end

def get_reservation_details
  #party_size
  puts "Enter party size."
  party_size = gets.strip
  puts
  until valid_party_size?(party_size)
    puts "Please enter a number. (min 1, max 10)"
    party_size = gets.strip
    puts
  end
  #date
  puts "Choose reservation date. (dd/mm/yyyy)"
  res_date = gets.strip
  puts
  until valid_reservation_date?(res_date)
    puts "Invalid date. Please enter a date with the format dd/mm/yyyy."
    res_date = gets.strip
    puts
  end
  #time
  if res_date.to_date == Date.today
    puts available_times.join(", ")
    puts "The above times are available. Please choose a reservation time. (hhmm)"
    res_time = gets.strip.to_i
    puts
    until valid_same_day_time?(res_time)
      puts available_times.join(", ")
      puts "The above times are available. Please choose a reservation time. (hhmm)"
      res_time = gets.strip.to_i
      puts
    end
  else
    puts all_times.join(", ")
    puts "The above times are available. Please select one of these times. (hhmm)"
    res_time = gets.strip.to_i
    puts
    until valid_reservation_time?(res_time)
      puts all_times.join(", ")
      puts "The above times are available. Please select one of these times. (hhmm)"
      res_time = gets.strip.to_i
      puts
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
  puts "Username not found. Would you like to sign up? y/n?"
  answer = gets.strip.downcase
  puts
  until answer == "y" || answer =="yes" || answer == "n" || answer == "no"
    puts "Invalid input. Would you like to sign up? y/n?"
    answer = gets.strip.downcase
    puts
  end
  if answer == "y" || answer =="yes"
    #username
    puts "Enter a username. Username must be between 6 and 16 characters with no special characters."
    username = gets.strip.downcase
    puts
    until valid_username?(username)
      username = gets.strip.downcase
      puts
    end
    #name
    puts "Enter your name."
    fullname = gets.strip
    puts
    puts "Enter your phone number. (xxx-xxx-xxxx)"
    phone_number = gets.strip
    puts
    until valid_phone_number?(phone_number)
      puts "Enter a valid phone number. (xxx-xxx-xxxx)"
      phone_number = gets.strip
      puts
    end
    #password
    puts "Enter a password. Password must be between 8 and 16 characters."
    password = gets.strip
    puts
    until valid_password?(password)
      puts "Password must be between 8 and 16 characters."
      password = gets.strip
      puts
    end
    #confirm
    puts "Confirm password."
    confirm = gets.strip
    puts
    until password == confirm
      puts "Passwords did not match."
      puts "confirm password."
      confirm = gets.strip
      puts
    end
    puts "🎉🎊 Username created! 🎊🎉"
    puts
    hash[:username] = username
    hash[:password] = password
    hash[:password_confirmation] = confirm
    hash[:fullname] = fullname
    hash[:phone_number] = phone_number
  else # answer == "n" || answer == "no"
    welcome
  end
  hash
end

def customer_create_password(customer_hash)
  customer = Customer.new(customer_hash)
  customer.save
  customer
end

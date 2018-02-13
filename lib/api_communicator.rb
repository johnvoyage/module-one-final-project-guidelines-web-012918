require 'rest-client'
require 'json'
require 'pry'
require 'nokogiri'
require 'open-uri'

# jason_api_key = "d5b63600443f3d619698a2aa133b3b62"
# john_api_key = "b3bc425599edde972d3b4f3460d82332"

def welcome
  puts "Welcome to Zomato API"
end

def goodbye
  puts "fuck off"
end

def invalid_zipcode
  puts "Please enter a valid 5-digit zipcode"
end

def invalid_input(nearby_restaurants)
  puts "Please enter a number between 1 and #{nearby_restaurants.length}"
end

def get_zipcode_from_user
  puts "Please enter your zipcode"
  input = gets.strip
  until input.length == 5 && input.to_i.is_a?(Fixnum) && input.to_i.to_s.length == 5 && check_zipcode(input)
    invalid_zipcode
    input = gets.strip
  end
  input
end

def check_zipcode(zipcode)
  api = RestClient.get("api.zippopotam.us/us/#{zipcode}"){|response, request, result| response }
  api != "RestClient::Response 404 \"{}\""
end

def get_lat(zipcode)
  api = RestClient.get("api.zippopotam.us/us/#{zipcode}")
  JSON.parse(api)["places"][0]["latitude"]
end

def get_long(zipcode)
  api = RestClient.get("api.zippopotam.us/us/#{zipcode}")
  JSON.parse(api)["places"][0]["longitude"]
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

def get_nearby_restaurants(parse_data)
  parse_data.map do |x|
    {name: x["restaurant"]["name"],
    cuisines: x["restaurant"]["cuisines"],
    price_range: "$" * x["restaurant"]["price_range"],
    zipcode: x["restaurant"]["location"]["zipcode"]}
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

def check_input_is_only_number(input)
  !(input.count("a-zA-Z") > 0)
end

def get_restaurant_from_user(nearby_restaurants)
  puts "Please select a restaurant to reserve a table at. (enter a number)"
  input = gets.strip
  until check_input_is_only_number(input) && input.to_i > 0 && input.to_i <= nearby_restaurants.length
    invalid_input(nearby_restaurants)
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
    reservation_confirm(reservation_details, restaurant_hash, customer)
  end
end

def restaurant_exist?(restaurant_hash)
  restaurant = Restaurant.find_by(name: restaurant_hash[:name], cuisines: restaurant_hash[:cuisines], zipcode: restaurant_hash[:zipcode])
end

def same_day_and_time_reservation?(reservation_details, customer)
  Reservation.where(date: reservation_details[:date], time: reservation_details[:time]).find_by(customer_id: customer.id)
end

def create_reservation(reservation_details, customer, restaurant)
  reservation = Reservation.new(reservation_details)
  reservation[:customer_id] = customer.id
  reservation[:restaurant_id] = restaurant.id
  reservation.save
end

def reservation_confirm(reservation_details, restaurant_hash, customer)
  puts "confirm reservation? y/n?"
  answer = gets.strip.downcase
  if answer == "y" || answer == "yes"
    restaurant = restaurant_exist?(restaurant_hash)
    if same_day_and_time_reservation?(reservation_details, customer)
      puts "You already have a reservation for that day and time"
    elsif restaurant
      reservation = create_reservation(reservation_details, customer, restaurant)
      puts "Your reservation for #{reservation_details[:party_size]} at #{restaurant[:name]} on #{reservation_details[:date]} #{reservation_details[:time]} has been confirmed!"
    else
      restaurant = Restaurant.create(restaurant_hash)
      reservation = create_reservation(reservation_details, customer, restaurant)
      puts "Your reservation for #{reservation_details[:party_size]} at #{restaurant[:name]} on #{reservation_details[:date]} #{reservation_details[:time]} has been confirmed!"
    end
  else
    goodbye
  end
end

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

def valid_party_size?(x)
  check_input_is_only_number(x) && x.to_i > 0
end

def valid_reservation_date?(date)
  date >= Date.today
end

def valid_reservation_time(time)
  time >= Time.now.hour.to_s + ":" + Time.now.min.to_s

end


def get_reservation_details
  puts "enter party size"
  party_size = gets.strip
  puts "choose reservation date (dd/mm/yyyy)"
  res_date = gets.strip
  puts "choose reservation time (hh:mm)"
  res_time = gets.strip

  hash = {}
  hash[:date] = res_date
  hash[:time] = res_time
  hash[:party_size] = party_size
  hash
end

def customer_create
  customer_hash = customer_sign_up
  customer_create_password(customer_hash)
end

def customer_sign_up
  puts "sign up? y/n?"
  answer = gets.strip.downcase
  if answer == "y" || answer =="yes"
    puts "enter a username"
    username = gets.strip.downcase
    puts "enter full name"
    fullname = gets.strip
    puts "enter phone number"
    phonenumber = gets.strip
    puts "enter a password"
    password = gets.strip
    puts "confirm password"
    confirm = gets.strip
    until password == confirm
      puts "password did not match"
      puts "confirm password"
      confirm = gets.strip
    end
    hash = {}
    hash[:username] = username
    hash[:password] = password
    hash[:password_confirmation] = confirm
    hash[:fullname] = fullname
    hash[:phone_number] = phonenumber
    hash
  else
    goodbye
  end
end

def customer_create_password(customer_hash)
  customer = Customer.new(customer_hash)
  customer.save
  customer
end

require 'rest-client'
require 'json'
require 'pry'
require 'nokogiri'
require 'open-uri'

# api_key = d5b63600443f3d619698a2aa133b3b62

def welcome
  # puts out a welcome message here!
  puts "Welcome to Zomato API"
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
  until input.length == 5 && input.to_i.is_a?(Fixnum) && input.to_i.to_s.length == 5
    invalid_zipcode
    input = gets.strip
  end
  input
end

def get_lat(zipcode)
  api = RestClient.get("api.zippopotam.us/us/#{zipcode}")
  JSON.parse(api)["places"][0]["latitude"]
end

def get_long(zipcode)
  api = RestClient.get("api.zippopotam.us/us/#{zipcode}")
  JSON.parse(api)["places"][0]["longitude"]
end

# we got flatiron's wifi blocked lol
# def get_lat(zipcode)
#   html = open("https://www.melissadata.com/lookups/GeoCoder.asp?InData=#{zipcode}&submit=Search")
#   doc = Nokogiri::HTML(html)
#   lat_long = doc.css(".padd").to_a.map {|x| x.text}[0].to_f
# end
#
# def get_long(zipcode)
#   html = open("https://www.melissadata.com/lookups/GeoCoder.asp?InData=#{zipcode}&submit=Search")
#   doc = Nokogiri::HTML(html)
#   lat_long = doc.css(".padd").to_a.map {|x| x.text}[1].to_f
# end

def parse_json_geocode(lat, long)
  uri = URI.parse("https://developers.zomato.com/api/v2.1/geocode?lat=#{lat}&lon=#{long}")
  request = Net::HTTP::Get.new(uri)
  request["Accept"] = "application/json"
  request["User-Key"] = "d5b63600443f3d619698a2aa133b3b62"

  req_options = {
    use_ssl: uri.scheme == "https",
  }

  response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
    http.request(request)
  end
  JSON.parse(response.body)["nearby_restaurants"]
end


def get_nearby_restaurants(parse_data)
  parse_data.map do |x|
    i = ""
    x["restaurant"]["price_range"].times do i += "$" end
    {name: x["restaurant"]["name"],
    cuisines: x["restaurant"]["cuisines"],
    price_range: i}
  end
end

def beautify_nearby_restaurants(nearby_restaurants)
  puts "These restaurants are nearby."
  x = 1
  this = nearby_restaurants.each do |restaurant|
    puts "#{x}. #{restaurant[:name]} -- #{restaurant[:cuisines]} -- #{restaurant[:price_range]}"
    x += 1
  end
  this
end

def get_restaurant_from_user(nearby_restaurants)
  binding.pry
  puts "Please select a restaurant (enter a number)"
  input = gets.strip
  until check_input_is_only_number(input) && input.to_i > 0 && input <= nearby_restaurants.length
    invalid_input(nearby_restaurants)
    input = gets.strip
  end
  input
end

def check_input_is_only_number(input)
  !(input.count("a-zA-Z") > 0)
end

def list_restaurants_and_cuisines
end

def list_restaurant_menu(restaurant)
end


# def get_character_movies_from_api(character)
#   #make the web request
#   all_characters = RestClient.get('http://www.swapi.co/api/people/')
#   character_hash = JSON.parse(all_characters)
#   # iterate over the character hash to find the collection of `films` for the given
#   #   `character`
#   results_hash = character_hash['results']
#   # puts results_hash.find {|elements| puts elements.find {|k, v| v == character}}
#   character_results_hash = results_hash.find {|char_data| char_data['name'].downcase == character}
#   film_links = character_results_hash['films']
#
#   films_api = film_links.map do |link|
#     RestClient.get(link)
#   end
#   films_api.map do |film|
#     JSON.parse(film)
#   end
#   # collect those film API urls, make a web request to each URL to get the info
#   #  for that film
#   # return value of this method should be collection of info about each film.
#   #  i.e. an array of hashes in which each hash reps a given film
#   # this collection will be the argument given to `parse_character_movies`
#   #  and that method will do some nice presentation stuff: puts out a list
#   #  of movies by title. play around with puts out other info about a given film.
# end
#
# def parse_character_movies(films_hash)
#   # some iteration magic and puts out the movies in a nice list
#   movie_list = films_hash.map do |link|
#     link['title']
#   end
#   puts movie_list
# end
#
#
#
# def show_character_movies(character)
#   films_hash = get_character_movies_from_api(character)
#   parse_character_movies(films_hash)
# end
#
#
#
# #
# # ## BONUS
# #
# # # that `get_character_movies_from_api` method is probably pretty long. Does it do more than one job?
# # # can you split it up into helper methods?
# #

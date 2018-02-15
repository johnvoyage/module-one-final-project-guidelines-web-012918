require 'pry'



def check_zipcode(zipcode)
  response = RestClient.get("api.zippopotam.us/us/#{zipcode}"){|response, request, result| response}
  response != "RestClient::Response 404 \"{}\"" && response.to_s != "{}"
end

# def check_zipcode_two(zipcode)
#   begin
#   file = open("api.zippopotam.us/us/#{zipcode}")
#   doc = Nokogiri::HTML(file) do
#     # handle doc
#   end
# rescue OpenURI::HTTPError => e
#   if e.message == '404 Not Found'
#     # handle 404 error
#   else
#     raise e
#   end
# end

def invalid_input(nearby_restaurants)
  puts "Please enter a number between 1 and #{nearby_restaurants.length}"
end

def check_input_is_only_number(input)
  input.count("1234567890") == input.length
end

def same_day_and_time_reservation?(reservation_details, customer)
  # binding.pry

  Reservation.where(date: reservation_details[:date], time: reservation_details[:time]).find_by(customer_id: customer.id)
end


def valid_party_size?(x)
  check_input_is_only_number(x) && x.to_i > 0 && x.to_i <= 10
end

def valid_reservation_date?(date)
  day = date[0..1]
  month = date[3..4]
  year = date[6..9]
  invalid_dates = ["3002", "3104", "3106", "3109", "3111"]
  if date.length != 10
    return false
  elsif day.to_i > 31
    return false
  elsif month.to_i > 12
    return false
  elsif year.to_i < Time.now.year
    return false
  elsif year.to_i == Time.now.year && month.to_i < Time.now.month
    return false
  elsif year.to_i == Time.now.year && month.to_i == Time.now.month && day.to_i < Time.now.day
    return false
  elsif invalid_dates.include?(day + month)
    return false
  else
    true
  end
end

def valid_same_day_time?(time)
  available_times.include? (time)
end

def valid_reservation_time?(time)
  all_times.include?(time)
end

def all_times
  reservation_times = [1100, 1115, 1130, 1145, 1200, 1215, 1230, 1245, 1300, 1315, 1330, 1345, 1400, 1415, 1430, 1445, 1500, 1515, 1530, 1545, 1600, 1615, 1630, 1645, 1700, 1715, 1730, 1745, 1800, 1815, 1830, 1845, 1900, 1915, 2000, 2015, 2030, 2045, 2100, 2115, 2130, 2145, 2200, 2215, 2230, 2245]
end

def available_times
  reservation_times = [1100, 1115, 1130, 1145, 1200, 1215, 1230, 1245, 1300, 1315, 1330, 1345, 1400, 1415, 1430, 1445, 1500, 1515, 1530, 1545, 1600, 1615, 1630, 1645, 1700, 1715, 1730, 1745, 1800, 1815, 1830, 1845, 1900, 1915, 2000, 2015, 2030, 2045, 2100, 2115, 2130, 2145, 2200, 2215, 2230, 2245]
  available_times = []
  hour = Time.now.hour.to_s
  min = ""
  if Time.now.min.to_s.length == 1
    min = "0" + Time.now.min.to_s
  else min = Time.now.min.to_s
  end
  time_now = hour + min
  available_times << reservation_times.select {|time| time > (time_now.to_i + 100)}
  available_times[0]
end

def time_format(military_time)
  hour = military_time[0..1]
  minutes = military_time[2..3]
  if military_time.to_i >= 1200 && military_time.to_i < 1300
    return "#{hour}:#{minutes} PM"
  elsif military_time.to_i >= 1300
    return "#{hour.to_i - 12}:#{minutes} PM"
  elsif hour.to_i.to_s.length == 1
    hour = hour.to_i.to_s
    return "#{hour}:#{minutes} AM"
  else
    return "#{hour}:#{minutes} AM"
  end
end

def valid_phone_number?(phone_number)
 if phone_number.length != 12
  return false
 end
 first_three = phone_number[0..2]
 second_three = phone_number[4..6]
 last_four = phone_number[8..12]
 check_input_is_only_number(first_three) && check_input_is_only_number(second_three) && check_input_is_only_number(last_four) && phone_number[3] == "-" && phone_number[7] == "-"
end

def valid_username?(username)
  if Customer.find_by(username: username)
    puts "username taken"
    false
  elsif !(username.length.between?(6, 16))
    puts "enter a username between 6 and 16 characters"
    false
  else
    true
  end
end

def valid_password?(password)
  password.length.between?(8, 16)
end

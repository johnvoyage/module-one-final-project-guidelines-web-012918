require 'rest-client'
require 'json'
require 'pry'
require 'nokogiri'
require 'open-uri'
require_relative 'welcome'
require_relative 'input_checks'

# time_format(time)
def manage_reservations
  user = sign_in_to_manage
  managing_options(user)

end

def sign_in_to_manage
  puts "Please sign in to manage your reservations."
  puts "Enter username."
  username = gets.strip
  puts
  customer = Customer.find_by(username: username)
  # username exists
  if customer
    get_password(customer)
    puts "Login successful!"
    puts
  else
    puts "Please make a username with your first reservation."
    puts
    welcome
  end
  customer
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

def managing_options(user)
  puts "Select from options below."
  puts "1. View all reservations."
  puts "2. Cancel a reservation."
  puts "3. Back to main."
  select_option(user)
end

def select_option(user)
  option = gets.strip.to_i
  until option.between?(1, 3)
    puts "invalid input"
    puts
    managing_options(user)
  end
  if option == 1
    puts
    option_1(user)
  elsif option == 2
    puts
    option_2(user)
  else
    puts
    welcome
  end
end

#view all reservations including cancelled
def option_1(user)
  all_reservations = Reservation.where(customer_id: user.id).order(:date)
  all_reservations.each do |reservation|
   restaurant = Restaurant.find_by(id: reservation.restaurant_id)
   cancelled = ""
   if reservation.cancelled == true
     cancelled = "Cancelled"
   else
     cancelled = "Confirmed"
   end
   puts "#{reservation.date} @ #{time_format(reservation.time.to_s)} -- #{restaurant.name} -- #{restaurant.address} -- Confirmation ##{reservation.id} -- #{cancelled}"
 end
 puts
 managing_options(user)
end

#cancel a reservation
def option_2(user)
  available_to_cancel = Reservation.where(customer_id: user.id, cancelled: false).order(:date)
  available_to_cancel.each do |reservation|
   restaurant_name = Restaurant.find_by(id: reservation.restaurant_id).name
   puts "#{reservation.date} @ #{time_format(reservation.time.to_s)} -- #{restaurant_name} -- Confirmation ##{reservation.id}"
  end

  puts "Please enter the confirmation # of the reservation you want to cancel."
  confirmation = gets.strip
  puts
  until check_input_is_only_number(confirmation) && confirmation != '0'
    puts "Please enter the confirmation # of the reservation you want to cancel."
    confirmation = gets.strip
    puts
  end

  reservation_to_cancel = Reservation.find_by(id: confirmation)
  if available_to_cancel.find_by(id: confirmation.to_i) == nil
    puts "This confirmation number was not found."
    puts
    managing_options(user)
  elsif available_to_cancel.find_by(customer_id: user.id)
    reservation_to_cancel.cancelled = true
    reservation_to_cancel.save
    puts "Your reservation has been cancelled. 😢"
    puts
    managing_options(user)
  else
    puts "This confirmation number was not found."
    puts
    managing_options(user)
  end

end

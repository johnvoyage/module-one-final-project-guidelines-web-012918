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
  puts "Please sign in"
  puts "enter username"
  username = gets.strip
  customer = Customer.find_by(username: username)
  # username exists
  if customer
    get_password(customer)
    puts "login successful!"
  else
    puts "Please make a username with your first reservation"
    welcome
  end
  customer
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
    managing_options
  end
  if option == 1
    option_1(user)
  elsif option == 2
    option_2(user)
  else
    welcome
  end
end

#view all reservations including cancelled
def option_1(user)
  all_reservations = Reservation.where(customer_id: user.id, cancelled: false)
  n = 1
  all_reservations.each do |reservation|
   restaurant_name = Restaurant.find_by(id: reservation.restaurant_id).name
   puts "#{n}. #{reservation.date} @ #{time_format(reservation.time.to_s)} -- #{restaurant_name} -- Confirmation ##{reservation.id}"
   n += 1
 end
 managing_options(user)
end

#cancel a reservation
def option_2(user)
  available_to_cancel = Reservation.where(customer_id: user.id, cancelled: false)
  n = 1
  available_to_cancel.each do |reservation|
   restaurant_name = Restaurant.find_by(id: reservation.restaurant_id).name
   puts "#{n}. #{reservation.date} @ #{time_format(reservation.time.to_s)} -- #{restaurant_name} -- Confirmation ##{reservation.id}"
   n += 1
  end

  puts "Please enter the confirmation # of the reservation you want to cancel."

  confirmation = gets.strip
  until check_input_is_only_number(confirmation)
    puts "Please enter the confirmation # of the reservation you want to cancel."
    confirmation = gets.strip
  end

  reservation_to_cancel = Reservation.all[confirmation.to_i - 1]

  if Reservation.all[confirmation.to_i - 1] == nil
    puts "This confirmation number was not found."
    managing_options(user)
  elsif Reservation.all[confirmation.to_i - 1].customer_id == user.id
    reservation_to_cancel.cancelled = true
    reservation_to_cancel.save
    puts "Your reservation has been cancelled."
    managing_options(user)
  else
    puts "This confirmation number was not found."
    managing_options(user)
  end

end

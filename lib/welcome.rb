require_relative 'make_reservation'
require_relative 'manage_reservations'

def welcome
  puts "Welcome to Reservations"
  puts "Press 1 to make a reservation."
  puts "Press 2 to manage reservations."
  puts "Type 'exit' to quit"
  input = gets.strip.downcase
  puts
  until input == "1" || input == "2" || input == 'exit'
    puts "Press 1 to make a reservation."
    puts "Press 2 to manage reservations."
    puts "Type 'exit' to quit"
    p
    input = gets.strip
  end
  if input == "exit"
    goodbye
    exit
  elsif input == "1"
    make_reservation
  else
    manage_reservations
  end
end

def goodbye
  puts "Thank you! Goodbye."
end

class Customer < ActiveRecord::Base

  has_many :reservations

  has_secure_password
end

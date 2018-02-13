class CreateCustomers < ActiveRecord::Migration[5.1]
  def change
    create_table :customers do |t|
      t.text :username
      t.text :password_digest
      t.text :fullname
      t.text :phone_number
      # t.timestamps
    end
  end
end

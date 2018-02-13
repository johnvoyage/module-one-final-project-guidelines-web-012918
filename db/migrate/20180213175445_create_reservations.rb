class CreateReservations < ActiveRecord::Migration[5.1]
  def change
    create_table :reservations do |t|
      t.integer :customer_id
      t.integer :restaurant_id
      t.date :date
      t.time :time
      t.integer :party_size
      t.boolean :cancelled
    end

    change_column_default :reservations, :cancelled, from: nil, to: false
  end
end

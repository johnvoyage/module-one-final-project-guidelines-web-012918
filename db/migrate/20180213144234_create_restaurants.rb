class CreateRestaurants < ActiveRecord::Migration[5.1]
  def change
    create_table :restaurants do |t|
      t.string :name
      t.string :zipcode
      t.string :cuisines
      t.string :price_range
      # t.timestamps
    end
  end
end

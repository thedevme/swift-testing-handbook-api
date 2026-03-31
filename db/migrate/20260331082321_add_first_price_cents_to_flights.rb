class AddFirstPriceCentsToFlights < ActiveRecord::Migration[8.1]
  def change
    add_column :flights, :first_price_cents, :integer
  end
end

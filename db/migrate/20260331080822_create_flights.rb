class CreateFlights < ActiveRecord::Migration[8.1]
  def change
    create_table :flights, id: :uuid do |t|
      t.string :flight_number, limit: 10, null: false
      t.references :route, type: :uuid, null: false, foreign_key: true
      t.references :aircraft, type: :uuid, null: false, foreign_key: { to_table: :aircraft }
      t.datetime :scheduled_departure_at, null: false
      t.datetime :scheduled_arrival_at, null: false
      t.integer :duration_minutes, null: false
      t.string :status, default: 'scheduled', null: false
      t.integer :delay_minutes
      t.string :diverted_to, limit: 3
      t.integer :economy_price_cents, null: false
      t.integer :comfort_plus_price_cents, null: false
      t.integer :business_price_cents, null: false

      t.timestamps
    end
    add_index :flights, :flight_number
    add_index :flights, :scheduled_departure_at
    add_index :flights, :status
  end
end

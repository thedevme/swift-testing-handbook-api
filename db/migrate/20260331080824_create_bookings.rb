class CreateBookings < ActiveRecord::Migration[8.1]
  def change
    create_table :bookings, id: :uuid do |t|
      t.references :api_key, type: :uuid, null: false, foreign_key: true
      t.references :flight, type: :uuid, null: false, foreign_key: true
      t.references :seat, type: :uuid, null: false, foreign_key: true
      t.string :passenger_name, limit: 100, null: false
      t.string :reference, limit: 6, null: false
      t.string :status, default: 'confirmed', null: false

      t.timestamps
    end
    add_index :bookings, :reference, unique: true
    add_index :bookings, [:api_key_id, :flight_id], unique: true, where: "status = 'confirmed'"
  end
end

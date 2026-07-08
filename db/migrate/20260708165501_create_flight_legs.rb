class CreateFlightLegs < ActiveRecord::Migration[8.1]
  def change
    create_table :flight_legs, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.references :itinerary, type: :uuid, null: false, foreign_key: true
      t.references :flight, type: :uuid, null: false, foreign_key: true
      t.references :seat, type: :uuid, null: false, foreign_key: true
      t.integer :leg_number, null: false
      t.string :status, default: 'confirmed', null: false

      t.timestamps
    end

    add_index :flight_legs, [:itinerary_id, :leg_number], unique: true
    add_index :flight_legs, :status
  end
end

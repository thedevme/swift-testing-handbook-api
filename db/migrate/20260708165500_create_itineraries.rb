class CreateItineraries < ActiveRecord::Migration[8.1]
  def change
    create_table :itineraries, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.references :api_key, type: :uuid, null: false, foreign_key: true
      t.string :passenger_name, limit: 100, null: false
      t.string :reference, limit: 8, null: false
      t.string :status, default: 'confirmed', null: false
      t.integer :total_price_cents, null: false, default: 0
      t.integer :leg_count, null: false, default: 0

      t.timestamps
    end

    add_index :itineraries, :reference, unique: true
    add_index :itineraries, :status
    add_index :itineraries, [:api_key_id, :status]
  end
end

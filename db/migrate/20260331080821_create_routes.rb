class CreateRoutes < ActiveRecord::Migration[8.1]
  def change
    create_table :routes, id: :uuid do |t|
      t.references :origin, type: :uuid, null: false, foreign_key: { to_table: :airports }
      t.references :destination, type: :uuid, null: false, foreign_key: { to_table: :airports }
      t.references :aircraft, type: :uuid, null: false, foreign_key: { to_table: :aircraft }
      t.integer :duration_minutes, null: false
      t.integer :departures_per_day, null: false
      t.string :flight_number_prefix, null: false
      t.boolean :is_international, default: false

      t.timestamps
    end
    add_index :routes, [:origin_id, :destination_id], unique: true
  end
end

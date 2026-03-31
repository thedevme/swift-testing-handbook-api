class CreateSeats < ActiveRecord::Migration[8.1]
  def change
    create_table :seats, id: :uuid do |t|
      t.references :flight, type: :uuid, null: false, foreign_key: true
      t.string :seat_number, limit: 4, null: false
      t.string :seat_class, null: false
      t.string :seat_type, null: false
      t.string :features, array: true, default: []
      t.boolean :is_available, default: true, null: false

      t.timestamps
    end
    add_index :seats, [:flight_id, :seat_number], unique: true
    add_index :seats, :seat_class
    add_index :seats, :is_available
  end
end

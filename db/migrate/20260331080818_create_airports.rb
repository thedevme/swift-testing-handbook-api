class CreateAirports < ActiveRecord::Migration[8.1]
  def change
    create_table :airports, id: :uuid do |t|
      t.string :code, limit: 3, null: false
      t.string :name, null: false
      t.string :city, null: false
      t.string :country, null: false
      t.decimal :latitude, precision: 10, scale: 6, null: false
      t.decimal :longitude, precision: 10, scale: 6, null: false
      t.boolean :is_international, default: false

      t.timestamps
    end
    add_index :airports, :code, unique: true
  end
end

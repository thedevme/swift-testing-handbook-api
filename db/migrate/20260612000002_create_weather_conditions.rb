class CreateWeatherConditions < ActiveRecord::Migration[8.1]
  def change
    create_table :weather_conditions, id: :uuid do |t|
      t.references :airport, null: false, foreign_key: true, type: :uuid
      t.date :forecast_date, null: false
      t.integer :temperature_f, null: false
      t.integer :feels_like_f
      t.string :condition, null: false # sunny, cloudy, rainy, snowy, etc.
      t.integer :humidity_percent
      t.integer :wind_speed_mph
      t.string :wind_direction # N, NE, E, SE, S, SW, W, NW
      t.integer :precipitation_chance_percent
      t.integer :visibility_miles
      t.string :icon # for frontend display

      t.timestamps
    end

    add_index :weather_conditions, [:airport_id, :forecast_date], unique: true
    add_index :weather_conditions, :forecast_date
  end
end

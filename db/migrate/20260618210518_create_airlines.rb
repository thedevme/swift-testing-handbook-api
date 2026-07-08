class CreateAirlines < ActiveRecord::Migration[8.1]
  def change
    create_table :airlines, id: :uuid do |t|
      t.string :code, null: false, limit: 2
      t.string :name, null: false
      t.string :logo_svg
      t.string :logo_png
      t.string :country
      t.string :airline_type # 'legacy', 'low_cost', 'regional'

      t.timestamps
    end

    add_index :airlines, :code, unique: true
    add_index :airlines, :name
  end
end

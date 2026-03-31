class CreateAircraft < ActiveRecord::Migration[8.1]
  def change
    create_table :aircraft, id: :uuid do |t|
      t.string :model, null: false
      t.integer :economy_seats, null: false
      t.integer :comfort_plus_seats, null: false
      t.integer :business_seats, null: false
      t.integer :total_seats, null: false

      t.timestamps
    end
  end
end

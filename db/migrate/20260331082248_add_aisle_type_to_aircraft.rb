class AddAisleTypeToAircraft < ActiveRecord::Migration[8.1]
  def change
    add_column :aircraft, :aisle_type, :string, default: 'single'
  end
end

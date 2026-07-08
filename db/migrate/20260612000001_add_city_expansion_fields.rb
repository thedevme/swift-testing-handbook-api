class AddCityExpansionFields < ActiveRecord::Migration[8.1]
  def change
    add_column :airports, :hub_tier, :integer, default: 3
    add_column :airports, :state, :string
    add_column :airports, :timezone, :string
    add_column :airports, :elevation_ft, :integer

    add_index :airports, :hub_tier
    add_index :airports, :state
  end
end

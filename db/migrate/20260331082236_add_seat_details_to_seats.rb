class AddSeatDetailsToSeats < ActiveRecord::Migration[8.1]
  def change
    add_column :seats, :row, :integer, null: false, default: 1
    add_column :seats, :column_letter, :string, limit: 1, null: false, default: 'A'
    add_column :seats, :deck, :string, limit: 10, null: false, default: 'main'

    add_index :seats, :deck
  end
end

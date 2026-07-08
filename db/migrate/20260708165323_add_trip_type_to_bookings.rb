class AddTripTypeToBookings < ActiveRecord::Migration[8.1]
  def change
    add_column :bookings, :trip_type, :string, default: 'one_way', null: false
    add_index :bookings, :trip_type
  end
end

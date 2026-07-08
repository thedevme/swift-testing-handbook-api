class AddRoundTripSupportToBookings < ActiveRecord::Migration[8.1]
  def change
    add_reference :bookings, :return_booking, type: :uuid,
                  foreign_key: { to_table: :bookings }, null: true, index: true
    add_column :bookings, :is_outbound, :boolean, default: true, null: false

    add_index :bookings, [:api_key_id, :return_booking_id]
    add_index :bookings, :is_outbound
  end
end

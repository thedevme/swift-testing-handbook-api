class Booking < ApplicationRecord
  belongs_to :api_key
  belongs_to :flight
  belongs_to :seat

  enum :status, {
    confirmed: 'confirmed',
    cancelled: 'cancelled'
  }

  validates :passenger_name, presence: true, length: { maximum: 100 }
  validates :reference, presence: true, uniqueness: true

  before_validation :generate_reference, on: :create
  after_create :mark_seat_unavailable
  after_update :release_seat, if: :cancelled?

  private

  def generate_reference
    self.reference ||= loop do
      ref = "#{flight.flight_number[0..1]}#{SecureRandom.alphanumeric(4).upcase}"
      break ref unless Booking.exists?(reference: ref)
    end
  end

  def mark_seat_unavailable
    seat.update!(is_available: false)
  end

  def release_seat
    seat.update!(is_available: true) if saved_change_to_status? && cancelled?
  end
end

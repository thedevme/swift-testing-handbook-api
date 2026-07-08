class FlightLeg < ApplicationRecord
  belongs_to :itinerary
  belongs_to :flight
  belongs_to :seat

  enum :status, {
    confirmed: 'confirmed',
    cancelled: 'cancelled'
  }

  validates :leg_number, presence: true,
                         uniqueness: { scope: :itinerary_id },
                         numericality: { greater_than: 0 }

  after_create :mark_seat_unavailable
  after_update :release_seat, if: :cancelled?

  delegate :origin, :destination, to: :flight

  private

  def mark_seat_unavailable
    seat.update!(is_available: false)
  end

  def release_seat
    seat.update!(is_available: true) if saved_change_to_status? && cancelled?
  end
end

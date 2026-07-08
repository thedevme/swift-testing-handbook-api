class Booking < ApplicationRecord
  belongs_to :api_key
  belongs_to :flight
  belongs_to :seat
  belongs_to :return_booking, class_name: 'Booking', optional: true
  has_one :outbound_booking, class_name: 'Booking', foreign_key: :return_booking_id

  enum :status, {
    confirmed: 'confirmed',
    cancelled: 'cancelled'
  }

  enum :trip_type, {
    one_way: 'one_way',
    round_trip: 'round_trip',
    multi_city: 'multi_city'
  }, prefix: true

  scope :round_trip, -> { where(trip_type: 'round_trip') }
  scope :outbound, -> { where(is_outbound: true) }
  scope :return_leg, -> { where(is_outbound: false) }
  scope :with_return, -> { includes(:return_booking) }

  validates :passenger_name, presence: true, length: { maximum: 100 }
  validates :reference, presence: true, uniqueness: true
  validate :return_flight_after_outbound, if: -> { trip_type == 'round_trip' && return_booking.present? }

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

  def return_flight_after_outbound
    return unless return_booking && is_outbound

    if return_booking.flight.scheduled_departure_at <= flight.scheduled_arrival_at
      errors.add(:return_booking, 'must depart after outbound flight arrival')
    end
  end

  def complete_trip
    if is_outbound?
      { outbound: self, return: return_booking }
    else
      { outbound: outbound_booking, return: self }
    end
  end
end

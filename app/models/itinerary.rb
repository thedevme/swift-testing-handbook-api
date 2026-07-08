class Itinerary < ApplicationRecord
  belongs_to :api_key
  has_many :flight_legs, dependent: :destroy
  has_many :flights, through: :flight_legs
  has_many :seats, through: :flight_legs

  enum :status, {
    confirmed: 'confirmed',
    cancelled: 'cancelled',
    partially_cancelled: 'partially_cancelled'
  }

  validates :passenger_name, presence: true, length: { maximum: 100 }
  validates :reference, presence: true, uniqueness: true
  validates :leg_count, numericality: { greater_than: 1, less_than_or_equal_to: 6 }

  before_validation :generate_reference, on: :create
  before_save :calculate_totals

  # Get legs in order
  def legs_in_order
    flight_legs.order(:leg_number)
  end

  # Get route summary (TPA → LAX → NRT → SYD)
  def route_summary
    legs = legs_in_order.includes(flight: { route: [:origin, :destination] })
    origins = legs.map { |leg| leg.flight.origin.code }
    final = legs.last.flight.destination.code
    (origins + [final]).join(' → ')
  end

  # Validate connection times and airports
  def valid_connections?
    legs = legs_in_order.includes(:flight)

    legs.each_cons(2) do |current_leg, next_leg|
      current_arrival = current_leg.flight.scheduled_arrival_at
      next_departure = next_leg.flight.scheduled_departure_at

      # Minimum 90 minutes connection time
      connection_minutes = ((next_departure - current_arrival) / 60).to_i
      if connection_minutes < 90
        errors.add(:base, "Connection between leg #{current_leg.leg_number} and #{next_leg.leg_number} is too short (#{connection_minutes} minutes, minimum 90)")
        return false
      end

      # Connection airports must match
      if current_leg.flight.destination.code != next_leg.flight.origin.code
        errors.add(:base, "Leg #{current_leg.leg_number} arrives at #{current_leg.flight.destination.code} but leg #{next_leg.leg_number} departs from #{next_leg.flight.origin.code}")
        return false
      end
    end

    true
  end

  # Cancel entire itinerary
  def cancel_all!
    ActiveRecord::Base.transaction do
      flight_legs.each do |leg|
        leg.cancelled! unless leg.cancelled?
      end
      self.cancelled!
    end
  end

  private

  def generate_reference
    self.reference ||= loop do
      ref = "MC#{SecureRandom.alphanumeric(6).upcase}"
      break ref unless Itinerary.exists?(reference: ref)
    end
  end

  def calculate_totals
    return unless flight_legs.loaded? || flight_legs.any?

    self.total_price_cents = flight_legs.sum { |leg| leg.seat.price_cents }
    self.leg_count = flight_legs.count
  end
end

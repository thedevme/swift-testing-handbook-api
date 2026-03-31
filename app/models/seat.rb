class Seat < ApplicationRecord
  belongs_to :flight
  has_one :booking

  enum :seat_class, {
    economy: 'economy',
    comfort_plus: 'comfort_plus',
    business: 'business'
  }

  enum :seat_type, {
    window: 'window',
    middle: 'middle',
    aisle: 'aisle'
  }, prefix: true

  validates :seat_number, presence: true
  validates :seat_number, uniqueness: { scope: :flight_id }

  scope :available, -> { where(is_available: true) }

  def price_cents
    case seat_class
    when 'economy' then flight.economy_price_cents
    when 'comfort_plus' then flight.comfort_plus_price_cents
    when 'business' then flight.business_price_cents
    end
  end
end

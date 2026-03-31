class Seat < ApplicationRecord
  belongs_to :flight
  has_one :booking

  # Note: seat_class stores 'first' in DB but enum key is first_class to avoid conflict with AR
  enum :seat_class, {
    economy: 'economy',
    comfort_plus: 'comfort_plus',
    business: 'business',
    first_class: 'first'
  }

  enum :seat_type, {
    window: 'window',
    middle: 'middle',
    aisle: 'aisle'
  }, prefix: true

  validates :seat_number, presence: true
  validates :seat_number, uniqueness: { scope: :flight_id }
  validates :row, presence: true
  validates :column_letter, presence: true
  validates :deck, presence: true

  scope :available, -> { where(is_available: true) }
  scope :on_deck, ->(deck) { where(deck: deck) }

  def price_cents
    case seat_class
    when 'economy' then flight.economy_price_cents
    when 'comfort_plus' then flight.comfort_plus_price_cents
    when 'business' then flight.business_price_cents
    when 'first' then flight.first_price_cents
    end
  end
end

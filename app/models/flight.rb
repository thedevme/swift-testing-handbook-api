class Flight < ApplicationRecord
  belongs_to :route
  belongs_to :aircraft

  has_many :seats, dependent: :destroy
  has_many :bookings

  enum :status, {
    scheduled: 'scheduled',
    on_time: 'on_time',
    delayed: 'delayed',
    boarding: 'boarding',
    departed: 'departed',
    arrived: 'arrived',
    cancelled: 'cancelled',
    diverted: 'diverted'
  }

  validates :flight_number, presence: true
  validates :scheduled_departure_at, :scheduled_arrival_at, presence: true
  validates :economy_price_cents, :comfort_plus_price_cents,
            presence: true, numericality: { greater_than: 0 }
  # Business and first are optional - not all aircraft have both
  validates :business_price_cents, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :first_price_cents, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  scope :bookable, -> { where.not(status: [:cancelled, :diverted, :departed, :arrived]) }

  delegate :origin, :destination, to: :route

  def in_air?
    now = Time.current
    now >= scheduled_departure_at && now <= scheduled_arrival_at && !cancelled? && !diverted?
  end

  def current_position
    return nil unless in_air?

    elapsed = Time.current - scheduled_departure_at
    total = scheduled_arrival_at - scheduled_departure_at
    progress = [[elapsed / total, 0].max, 1].min

    origin_coords = Airport::COORDINATES[origin.code]
    dest_coords = Airport::COORDINATES[destination.code]

    return nil unless origin_coords && dest_coords

    {
      lat: origin_coords[:lat] + (dest_coords[:lat] - origin_coords[:lat]) * progress,
      lng: origin_coords[:lng] + (dest_coords[:lng] - origin_coords[:lng]) * progress,
      progress_pct: (progress * 100).round
    }
  end

  def time_remaining_minutes
    return nil unless in_air?
    ((scheduled_arrival_at - Time.current) / 60).round
  end
end

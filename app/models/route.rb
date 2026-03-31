class Route < ApplicationRecord
  belongs_to :origin, class_name: 'Airport'
  belongs_to :destination, class_name: 'Airport'
  belongs_to :aircraft

  has_many :flights

  validates :duration_minutes, :departures_per_day, presence: true
  validates :flight_number_prefix, presence: true
end

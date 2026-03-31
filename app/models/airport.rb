class Airport < ApplicationRecord
  has_many :departing_routes, class_name: 'Route', foreign_key: :origin_id
  has_many :arriving_routes, class_name: 'Route', foreign_key: :destination_id

  validates :code, presence: true, uniqueness: true, length: { is: 3 }
  validates :name, :city, :country, presence: true
  validates :latitude, :longitude, presence: true

  COORDINATES = {
    "TPA" => { lat: 27.9755, lng: -82.5332 },
    "JFK" => { lat: 40.6413, lng: -73.7781 },
    "LAX" => { lat: 33.9425, lng: -118.4081 },
    "ORD" => { lat: 41.9742, lng: -87.9073 },
    "BOS" => { lat: 42.3656, lng: -71.0096 },
    "MIA" => { lat: 25.7959, lng: -80.2870 },
    "SEA" => { lat: 47.4502, lng: -122.3088 },
    "DEN" => { lat: 39.8561, lng: -104.6737 },
    "ATL" => { lat: 33.6407, lng: -84.4277 },
    "DFW" => { lat: 32.8998, lng: -97.0403 },
    "LHR" => { lat: 51.4700, lng: -0.4543 },
    "CDG" => { lat: 49.0097, lng: 2.5479 },
    "NRT" => { lat: 35.7720, lng: 140.3929 },
    "SYD" => { lat: -33.9399, lng: 151.1753 },
    "DXB" => { lat: 25.2532, lng: 55.3657 },
    "YYZ" => { lat: 43.6777, lng: -79.6248 },
    "MEX" => { lat: 19.4363, lng: -99.0721 },
    "AMS" => { lat: 52.3105, lng: 4.7683 },
    "SIN" => { lat: 1.3644, lng: 103.9915 },
    "GRU" => { lat: -23.4356, lng: -46.4731 }
  }.freeze
end

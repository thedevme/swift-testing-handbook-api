class Airport < ApplicationRecord
  has_many :departing_routes, class_name: 'Route', foreign_key: :origin_id
  has_many :arriving_routes, class_name: 'Route', foreign_key: :destination_id
  has_many :weather_conditions, dependent: :destroy

  validates :code, presence: true, uniqueness: true, length: { is: 3 }
  validates :name, :city, :country, presence: true
  validates :latitude, :longitude, presence: true

  # Hub tier scopes for route generation
  scope :tier_1_hubs, -> { where(hub_tier: 1) }
  scope :tier_2_hubs, -> { where(hub_tier: 2) }
  scope :spoke_cities, -> { where(hub_tier: 3) }
  scope :domestic, -> { where(is_international: false) }
  scope :international, -> { where(is_international: true) }

  # Hub methods
  def hub?
    hub_tier && hub_tier <= 2
  end

  def major_hub?
    hub_tier == 1
  end

  # Get weather for a specific date
  def weather_for(date = Date.current)
    weather_conditions.find_by(forecast_date: date)
  end

  # Get current weather
  def current_weather
    weather_for(Date.current)
  end

  COORDINATES = {
    # US Major Hubs
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
    "LAS" => { lat: 36.0840, lng: -115.1537 },
    "SFO" => { lat: 37.6213, lng: -122.3790 },
    # US Mid-Size
    "PHX" => { lat: 33.4342, lng: -112.0080 },
    "MSP" => { lat: 44.8848, lng: -93.2223 },
    "DTW" => { lat: 42.2124, lng: -83.3534 },
    "EWR" => { lat: 40.6895, lng: -74.1745 },
    "PHL" => { lat: 39.8729, lng: -75.2437 },
    "CLT" => { lat: 35.2140, lng: -80.9431 },
    "MCO" => { lat: 28.4294, lng: -81.3089 },
    "IAH" => { lat: 29.9902, lng: -95.3368 },
    "SLC" => { lat: 40.7899, lng: -111.9791 },
    "PDX" => { lat: 45.5898, lng: -122.5951 },
    "SAN" => { lat: 32.7338, lng: -117.1933 },
    "AUS" => { lat: 30.1975, lng: -97.6664 },
    # US Regional
    "RDU" => { lat: 35.8776, lng: -78.7875 },
    "BNA" => { lat: 36.1245, lng: -86.6782 },
    "STL" => { lat: 38.7487, lng: -90.3700 },
    "CVG" => { lat: 39.0488, lng: -84.6678 },
    "PIT" => { lat: 40.4915, lng: -80.2329 },
    "IND" => { lat: 39.7173, lng: -86.2944 },
    "MKE" => { lat: 42.9472, lng: -87.8966 },
    "RNO" => { lat: 39.4991, lng: -119.7681 },
    "BUF" => { lat: 42.9405, lng: -78.7322 },
    "OMA" => { lat: 41.3032, lng: -95.8941 },
    "SAT" => { lat: 29.5337, lng: -98.4698 },
    "JAX" => { lat: 30.4941, lng: -81.6879 },
    "BDL" => { lat: 41.9389, lng: -72.6832 },
    "SMF" => { lat: 38.6954, lng: -121.5901 },
    "RSW" => { lat: 26.5362, lng: -81.7552 },
    "ABQ" => { lat: 35.0402, lng: -106.6092 },
    # Europe
    "LHR" => { lat: 51.4700, lng: -0.4543 },
    "CDG" => { lat: 49.0097, lng: 2.5479 },
    "AMS" => { lat: 52.3105, lng: 4.7683 },
    "DUB" => { lat: 53.4264, lng: -6.2499 },
    "FRA" => { lat: 50.0379, lng: 8.5622 },
    "MAD" => { lat: 40.4983, lng: -3.5676 },
    "FCO" => { lat: 41.8003, lng: 12.2389 },
    "ZRH" => { lat: 47.4647, lng: 8.5492 },
    "CPH" => { lat: 55.6180, lng: 12.6508 },
    "VIE" => { lat: 48.1103, lng: 16.5697 },
    "MUC" => { lat: 48.3538, lng: 11.7861 },
    # Asia-Pacific
    "NRT" => { lat: 35.7720, lng: 140.3929 },
    "SYD" => { lat: -33.9399, lng: 151.1753 },
    "SIN" => { lat: 1.3644, lng: 103.9915 },
    "HKG" => { lat: 22.3080, lng: 113.9185 },
    "ICN" => { lat: 37.4602, lng: 126.4407 },
    "BKK" => { lat: 13.6900, lng: 100.7501 },
    "PVG" => { lat: 31.1443, lng: 121.8083 },
    "PEK" => { lat: 40.0799, lng: 116.6031 },
    "DEL" => { lat: 28.5665, lng: 77.1031 },
    # Middle East & Africa
    "DXB" => { lat: 25.2532, lng: 55.3657 },
    "DOH" => { lat: 25.2731, lng: 51.6080 },
    "CAI" => { lat: 30.1219, lng: 31.4056 },
    "JNB" => { lat: -26.1367, lng: 28.2411 },
    # Latin America & Canada
    "YYZ" => { lat: 43.6777, lng: -79.6248 },
    "MEX" => { lat: 19.4363, lng: -99.0721 },
    "GRU" => { lat: -23.4356, lng: -46.4731 },
    "BOG" => { lat: 4.7016, lng: -74.1469 },
    "SCL" => { lat: -33.3930, lng: -70.7858 },
    "EZE" => { lat: -34.8222, lng: -58.5358 },
    "LIM" => { lat: -12.0219, lng: -77.1143 },
    "PTY" => { lat: 9.0714, lng: -79.3834 }
  }.freeze
end

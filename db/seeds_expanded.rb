# EXPANDED SEED FILE - 70 Cities with Weather
# Run with: rails db:seed:replant
# Or copy this to db/seeds.rb

puts "=" * 80
puts "EXPANDED FLIGHT API SEED - 70 Cities + Weather"
puts "=" * 80

# Clear existing data
puts "\n🗑️  Clearing existing data..."
WeatherCondition.delete_all
Booking.delete_all
Seat.delete_all
Flight.delete_all
Route.delete_all
Aircraft.delete_all
Airport.delete_all

puts "✅ Data cleared"

# =======================
# AIRCRAFT TYPES
# =======================
puts "\n✈️  Creating aircraft types..."

aircraft_configs = [
  {
    model: 'Boeing 737-800',
    economy_seats: 138,
    comfort_plus_seats: 14,
    business_seats: 0,
    first_seats: 8,
    total_seats: 160,
    aisle_type: 'single',
    layout: {
      first: { rows: 1..2, columns: %w[A C D F], layout: '2-2' },
      comfort_plus: { rows: 7..9, columns: %w[A B C D E F], layout: '3-3' },
      economy: { rows: 10..32, columns: %w[A B C D E F], layout: '3-3' }
    }
  },
  {
    model: 'Airbus A320',
    economy_seats: 132,
    comfort_plus_seats: 12,
    business_seats: 0,
    first_seats: 6,
    total_seats: 150,
    aisle_type: 'single',
    layout: {
      first: { rows: 1..2, columns: %w[A C D F], layout: '2-2' },
      comfort_plus: { rows: 7..8, columns: %w[A B C D E F], layout: '3-3' },
      economy: { rows: 9..30, columns: %w[A B C D E F], layout: '3-3' }
    }
  },
  {
    model: 'Boeing 757-200',
    economy_seats: 176,
    comfort_plus_seats: 20,
    business_seats: 0,
    first_seats: 12,
    total_seats: 208,
    aisle_type: 'single',
    layout: {
      first: { rows: 1..3, columns: %w[A C D F], layout: '2-2' },
      comfort_plus: { rows: 8..11, columns: %w[A B C D E F], layout: '3-3' },
      economy: { rows: 12..40, columns: %w[A B C D E F], layout: '3-3' }
    }
  },
  {
    model: 'Airbus A330-300',
    economy_seats: 198,
    comfort_plus_seats: 24,
    business_seats: 20,
    first_seats: 0,
    total_seats: 242,
    aisle_type: 'twin',
    layout: {
      business: { rows: 1..5, columns: %w[A C D E G K], layout: '2-2-2' },
      comfort_plus: { rows: 8..10, columns: %w[A B D E F G J K], layout: '2-4-2' },
      economy: { rows: 11..35, columns: %w[A B D E F G J K], layout: '2-4-2' }
    }
  },
  {
    model: 'Boeing 777-200',
    economy_seats: 226,
    comfort_plus_seats: 28,
    business_seats: 28,
    first_seats: 0,
    total_seats: 282,
    aisle_type: 'twin',
    layout: {
      business: { rows: 1..7, columns: %w[A C D E G J K], layout: '2-3-2' },
      comfort_plus: { rows: 8..11, columns: %w[A B C D E F G H J], layout: '3-3-3' },
      economy: { rows: 12..40, columns: %w[A B C D E F G H J], layout: '3-3-3' }
    }
  },
  {
    model: 'Airbus A380-800',
    economy_seats: 399,
    comfort_plus_seats: 64,
    business_seats: 76,
    first_seats: 14,
    total_seats: 553,
    aisle_type: 'twin',
    layout: {
      first: { rows: 1..7, columns: %w[A D G K], deck: 'upper', layout: '1-2-1' },
      business: { rows: 8..26, columns: %w[A C D E F G J K], deck: 'upper', layout: '2-4-2' },
      comfort_plus: { rows: 11..16, columns: %w[A B C D E F G H J K], deck: 'main', layout: '3-4-3' },
      economy: { rows: 17..51, columns: %w[A B C D E F G H J K], deck: 'main', layout: '3-4-3' }
    }
  },
  {
    model: 'Boeing 767-300',
    economy_seats: 180,
    comfort_plus_seats: 21,
    business_seats: 17,
    first_seats: 0,
    total_seats: 218,
    aisle_type: 'twin',
    layout: {
      business: { rows: 1..4, columns: %w[A C D E G K], layout: '2-2-2' },
      comfort_plus: { rows: 8..10, columns: %w[A B D E F G K], layout: '2-3-2' },
      economy: { rows: 11..36, columns: %w[A B D E F G K], layout: '2-3-2' }
    }
  }
]

aircraft = {}
aircraft_configs.each do |config|
  ac = Aircraft.create!(
    model: config[:model],
    economy_seats: config[:economy_seats],
    comfort_plus_seats: config[:comfort_plus_seats],
    business_seats: config[:business_seats],
    first_seats: config[:first_seats],
    total_seats: config[:total_seats],
    aisle_type: config[:aisle_type]
  )
  aircraft[config[:model]] = { record: ac, layout: config[:layout] }
end
puts "✅ Created #{aircraft.count} aircraft types"

# =======================
# AIRPORTS - 70 CITIES
# =======================
puts "\n🌍 Creating 70 airports..."

airports_data = [
  # ===== TIER 1 MAJOR HUBS (18 airports) =====
  # Existing major hubs
  { code: 'ATL', name: 'Hartsfield-Jackson International', city: 'Atlanta', state: 'GA', country: 'USA', latitude: 33.6407, longitude: -84.4277, is_international: false, hub_tier: 1, timezone: 'America/New_York', elevation_ft: 1026 },
  { code: 'ORD', name: "O'Hare International", city: 'Chicago', state: 'IL', country: 'USA', latitude: 41.9742, longitude: -87.9073, is_international: false, hub_tier: 1, timezone: 'America/Chicago', elevation_ft: 672 },
  { code: 'DFW', name: 'Dallas/Fort Worth International', city: 'Dallas', state: 'TX', country: 'USA', latitude: 32.8998, longitude: -97.0403, is_international: false, hub_tier: 1, timezone: 'America/Chicago', elevation_ft: 607 },
  { code: 'DEN', name: 'Denver International', city: 'Denver', state: 'CO', country: 'USA', latitude: 39.8561, longitude: -104.6737, is_international: false, hub_tier: 1, timezone: 'America/Denver', elevation_ft: 5431 },
  { code: 'LAX', name: 'Los Angeles International', city: 'Los Angeles', state: 'CA', country: 'USA', latitude: 33.9425, longitude: -118.4081, is_international: false, hub_tier: 1, timezone: 'America/Los_Angeles', elevation_ft: 125 },
  { code: 'JFK', name: 'John F. Kennedy International', city: 'New York', state: 'NY', country: 'USA', latitude: 40.6413, longitude: -73.7781, is_international: false, hub_tier: 1, timezone: 'America/New_York', elevation_ft: 13 },

  # NEW major hubs
  { code: 'SFO', name: 'San Francisco International', city: 'San Francisco', state: 'CA', country: 'USA', latitude: 37.6213, longitude: -122.3790, is_international: false, hub_tier: 1, timezone: 'America/Los_Angeles', elevation_ft: 13 },
  { code: 'PHX', name: 'Phoenix Sky Harbor International', city: 'Phoenix', state: 'AZ', country: 'USA', latitude: 33.4342, longitude: -112.0080, is_international: false, hub_tier: 1, timezone: 'America/Phoenix', elevation_ft: 1135 },
  { code: 'MSP', name: 'Minneapolis-St Paul International', city: 'Minneapolis', state: 'MN', country: 'USA', latitude: 44.8848, longitude: -93.2223, is_international: false, hub_tier: 1, timezone: 'America/Chicago', elevation_ft: 841 },
  { code: 'DTW', name: 'Detroit Metropolitan Wayne County', city: 'Detroit', state: 'MI', country: 'USA', latitude: 42.2124, longitude: -83.3534, is_international: false, hub_tier: 1, timezone: 'America/Detroit', elevation_ft: 645 },
  { code: 'EWR', name: 'Newark Liberty International', city: 'Newark', state: 'NJ', country: 'USA', latitude: 40.6895, longitude: -74.1745, is_international: false, hub_tier: 1, timezone: 'America/New_York', elevation_ft: 18 },
  { code: 'CLT', name: 'Charlotte Douglas International', city: 'Charlotte', state: 'NC', country: 'USA', latitude: 35.2140, longitude: -80.9431, is_international: false, hub_tier: 1, timezone: 'America/New_York', elevation_ft: 748 },
  { code: 'IAH', name: 'George Bush Intercontinental', city: 'Houston', state: 'TX', country: 'USA', latitude: 29.9902, longitude: -95.3368, is_international: false, hub_tier: 1, timezone: 'America/Chicago', elevation_ft: 97 },
  { code: 'SLC', name: 'Salt Lake City International', city: 'Salt Lake City', state: 'UT', country: 'USA', latitude: 40.7899, longitude: -111.9791, is_international: false, hub_tier: 1, timezone: 'America/Denver', elevation_ft: 4227 },
  { code: 'BOS', name: 'Logan International', city: 'Boston', state: 'MA', country: 'USA', latitude: 42.3656, longitude: -71.0096, is_international: false, hub_tier: 1, timezone: 'America/New_York', elevation_ft: 19 },
  { code: 'MIA', name: 'Miami International', city: 'Miami', state: 'FL', country: 'USA', latitude: 25.7959, longitude: -80.2870, is_international: false, hub_tier: 1, timezone: 'America/New_York', elevation_ft: 8 },
  { code: 'SEA', name: 'Seattle-Tacoma International', city: 'Seattle', state: 'WA', country: 'USA', latitude: 47.4502, longitude: -122.3088, is_international: false, hub_tier: 1, timezone: 'America/Los_Angeles', elevation_ft: 433 },
  { code: 'LAS', name: 'Harry Reid International', city: 'Las Vegas', state: 'NV', country: 'USA', latitude: 36.0840, longitude: -115.1537, is_international: false, hub_tier: 1, timezone: 'America/Los_Angeles', elevation_ft: 2181 },

  # ===== TIER 2 REGIONAL HUBS (12 airports) =====
  { code: 'TPA', name: 'Tampa International', city: 'Tampa', state: 'FL', country: 'USA', latitude: 27.9755, longitude: -82.5332, is_international: false, hub_tier: 2, timezone: 'America/New_York', elevation_ft: 26 },
  { code: 'MCO', name: 'Orlando International', city: 'Orlando', state: 'FL', country: 'USA', latitude: 28.4294, longitude: -81.3089, is_international: false, hub_tier: 2, timezone: 'America/New_York', elevation_ft: 96 },
  { code: 'PHL', name: 'Philadelphia International', city: 'Philadelphia', state: 'PA', country: 'USA', latitude: 39.8729, longitude: -75.2437, is_international: false, hub_tier: 2, timezone: 'America/New_York', elevation_ft: 36 },
  { code: 'PDX', name: 'Portland International', city: 'Portland', state: 'OR', country: 'USA', latitude: 45.5898, longitude: -122.5951, is_international: false, hub_tier: 2, timezone: 'America/Los_Angeles', elevation_ft: 30 },
  { code: 'SAN', name: 'San Diego International', city: 'San Diego', state: 'CA', country: 'USA', latitude: 32.7338, longitude: -117.1933, is_international: false, hub_tier: 2, timezone: 'America/Los_Angeles', elevation_ft: 17 },
  { code: 'AUS', name: 'Austin-Bergstrom International', city: 'Austin', state: 'TX', country: 'USA', latitude: 30.1975, longitude: -97.6664, is_international: false, hub_tier: 2, timezone: 'America/Chicago', elevation_ft: 542 },
  { code: 'RDU', name: 'Raleigh-Durham International', city: 'Raleigh', state: 'NC', country: 'USA', latitude: 35.8776, longitude: -78.7875, is_international: false, hub_tier: 2, timezone: 'America/New_York', elevation_ft: 435 },
  { code: 'BNA', name: 'Nashville International', city: 'Nashville', state: 'TN', country: 'USA', latitude: 36.1245, longitude: -86.6782, is_international: false, hub_tier: 2, timezone: 'America/Chicago', elevation_ft: 599 },
  { code: 'STL', name: 'St. Louis Lambert International', city: 'St. Louis', state: 'MO', country: 'USA', latitude: 38.7487, longitude: -90.3700, is_international: false, hub_tier: 2, timezone: 'America/Chicago', elevation_ft: 618 },
  { code: 'CVG', name: 'Cincinnati/Northern Kentucky International', city: 'Cincinnati', state: 'OH', country: 'USA', latitude: 39.0488, longitude: -84.6678, is_international: false, hub_tier: 2, timezone: 'America/New_York', elevation_ft: 896 },
  { code: 'PIT', name: 'Pittsburgh International', city: 'Pittsburgh', state: 'PA', country: 'USA', latitude: 40.4915, longitude: -80.2329, is_international: false, hub_tier: 2, timezone: 'America/New_York', elevation_ft: 1203 },
  { code: 'IND', name: 'Indianapolis International', city: 'Indianapolis', state: 'IN', country: 'USA', latitude: 39.7173, longitude: -86.2944, is_international: false, hub_tier: 2, timezone: 'America/Indiana/Indianapolis', elevation_ft: 797 },

  # ===== TIER 3 SPOKE CITIES (10 airports) =====
  { code: 'RNO', name: 'Reno-Tahoe International', city: 'Reno', state: 'NV', country: 'USA', latitude: 39.4991, longitude: -119.7681, is_international: false, hub_tier: 3, timezone: 'America/Los_Angeles', elevation_ft: 4415 },
  { code: 'BUF', name: 'Buffalo Niagara International', city: 'Buffalo', state: 'NY', country: 'USA', latitude: 42.9405, longitude: -78.7322, is_international: false, hub_tier: 3, timezone: 'America/New_York', elevation_ft: 728 },
  { code: 'OMA', name: 'Eppley Airfield', city: 'Omaha', state: 'NE', country: 'USA', latitude: 41.3032, longitude: -95.8941, is_international: false, hub_tier: 3, timezone: 'America/Chicago', elevation_ft: 984 },
  { code: 'SAT', name: 'San Antonio International', city: 'San Antonio', state: 'TX', country: 'USA', latitude: 29.5337, longitude: -98.4698, is_international: false, hub_tier: 3, timezone: 'America/Chicago', elevation_ft: 809 },
  { code: 'JAX', name: 'Jacksonville International', city: 'Jacksonville', state: 'FL', country: 'USA', latitude: 30.4941, longitude: -81.6879, is_international: false, hub_tier: 3, timezone: 'America/New_York', elevation_ft: 30 },
  { code: 'BDL', name: 'Bradley International', city: 'Hartford', state: 'CT', country: 'USA', latitude: 41.9389, longitude: -72.6832, is_international: false, hub_tier: 3, timezone: 'America/New_York', elevation_ft: 173 },
  { code: 'SMF', name: 'Sacramento International', city: 'Sacramento', state: 'CA', country: 'USA', latitude: 38.6954, longitude: -121.5901, is_international: false, hub_tier: 3, timezone: 'America/Los_Angeles', elevation_ft: 27 },
  { code: 'RSW', name: 'Southwest Florida International', city: 'Fort Myers', state: 'FL', country: 'USA', latitude: 26.5362, longitude: -81.7552, is_international: false, hub_tier: 3, timezone: 'America/New_York', elevation_ft: 30 },
  { code: 'ABQ', name: 'Albuquerque International Sunport', city: 'Albuquerque', state: 'NM', country: 'USA', latitude: 35.0402, longitude: -106.6092, is_international: false, hub_tier: 3, timezone: 'America/Denver', elevation_ft: 5355 },
  { code: 'OAK', name: 'Oakland International', city: 'Oakland', state: 'CA', country: 'USA', latitude: 37.7213, longitude: -122.2208, is_international: false, hub_tier: 3, timezone: 'America/Los_Angeles', elevation_ft: 9 },

  # ===== INTERNATIONAL - EUROPE (11 airports) =====
  { code: 'LHR', name: 'Heathrow', city: 'London', state: nil, country: 'UK', latitude: 51.4700, longitude: -0.4543, is_international: true, hub_tier: 1, timezone: 'Europe/London', elevation_ft: 83 },
  { code: 'CDG', name: 'Charles de Gaulle', city: 'Paris', state: nil, country: 'France', latitude: 49.0097, longitude: 2.5479, is_international: true, hub_tier: 1, timezone: 'Europe/Paris', elevation_ft: 392 },
  { code: 'AMS', name: 'Amsterdam Schiphol', city: 'Amsterdam', state: nil, country: 'Netherlands', latitude: 52.3105, longitude: 4.7683, is_international: true, hub_tier: 1, timezone: 'Europe/Amsterdam', elevation_ft: -11 },
  { code: 'DUB', name: 'Dublin Airport', city: 'Dublin', state: nil, country: 'Ireland', latitude: 53.4264, longitude: -6.2499, is_international: true, hub_tier: 2, timezone: 'Europe/Dublin', elevation_ft: 242 },
  { code: 'FRA', name: 'Frankfurt Airport', city: 'Frankfurt', state: nil, country: 'Germany', latitude: 50.0379, longitude: 8.5622, is_international: true, hub_tier: 1, timezone: 'Europe/Berlin', elevation_ft: 364 },
  { code: 'MAD', name: 'Adolfo Suárez Madrid-Barajas', city: 'Madrid', state: nil, country: 'Spain', latitude: 40.4983, longitude: -3.5676, is_international: true, hub_tier: 1, timezone: 'Europe/Madrid', elevation_ft: 1998 },
  { code: 'FCO', name: 'Leonardo da Vinci-Fiumicino', city: 'Rome', state: nil, country: 'Italy', latitude: 41.8003, longitude: 12.2389, is_international: true, hub_tier: 1, timezone: 'Europe/Rome', elevation_ft: 13 },
  { code: 'ZRH', name: 'Zurich Airport', city: 'Zurich', state: nil, country: 'Switzerland', latitude: 47.4647, longitude: 8.5492, is_international: true, hub_tier: 1, timezone: 'Europe/Zurich', elevation_ft: 1416 },
  { code: 'CPH', name: 'Copenhagen Airport', city: 'Copenhagen', state: nil, country: 'Denmark', latitude: 55.6180, longitude: 12.6508, is_international: true, hub_tier: 1, timezone: 'Europe/Copenhagen', elevation_ft: 17 },
  { code: 'VIE', name: 'Vienna International Airport', city: 'Vienna', state: nil, country: 'Austria', latitude: 48.1103, longitude: 16.5697, is_international: true, hub_tier: 1, timezone: 'Europe/Vienna', elevation_ft: 600 },
  { code: 'MUC', name: 'Munich Airport', city: 'Munich', state: nil, country: 'Germany', latitude: 48.3538, longitude: 11.7861, is_international: true, hub_tier: 1, timezone: 'Europe/Berlin', elevation_ft: 1487 },

  # ===== INTERNATIONAL - ASIA-PACIFIC (10 airports) =====
  { code: 'NRT', name: 'Narita International', city: 'Tokyo', state: nil, country: 'Japan', latitude: 35.7720, longitude: 140.3929, is_international: true, hub_tier: 1, timezone: 'Asia/Tokyo', elevation_ft: 141 },
  { code: 'SYD', name: 'Sydney Kingsford Smith', city: 'Sydney', state: nil, country: 'Australia', latitude: -33.9399, longitude: 151.1753, is_international: true, hub_tier: 1, timezone: 'Australia/Sydney', elevation_ft: 21 },
  { code: 'SIN', name: 'Singapore Changi', city: 'Singapore', state: nil, country: 'Singapore', latitude: 1.3644, longitude: 103.9915, is_international: true, hub_tier: 1, timezone: 'Asia/Singapore', elevation_ft: 22 },
  { code: 'HKG', name: 'Hong Kong International', city: 'Hong Kong', state: nil, country: 'China', latitude: 22.3080, longitude: 113.9185, is_international: true, hub_tier: 1, timezone: 'Asia/Hong_Kong', elevation_ft: 28 },
  { code: 'ICN', name: 'Incheon International', city: 'Seoul', state: nil, country: 'South Korea', latitude: 37.4602, longitude: 126.4407, is_international: true, hub_tier: 1, timezone: 'Asia/Seoul', elevation_ft: 23 },
  { code: 'BKK', name: 'Suvarnabhumi Airport', city: 'Bangkok', state: nil, country: 'Thailand', latitude: 13.6900, longitude: 100.7501, is_international: true, hub_tier: 1, timezone: 'Asia/Bangkok', elevation_ft: 5 },
  { code: 'PVG', name: 'Shanghai Pudong International', city: 'Shanghai', state: nil, country: 'China', latitude: 31.1443, longitude: 121.8083, is_international: true, hub_tier: 1, timezone: 'Asia/Shanghai', elevation_ft: 13 },
  { code: 'PEK', name: 'Beijing Capital International', city: 'Beijing', state: nil, country: 'China', latitude: 40.0799, longitude: 116.6031, is_international: true, hub_tier: 1, timezone: 'Asia/Shanghai', elevation_ft: 116 },
  { code: 'DEL', name: 'Indira Gandhi International', city: 'Delhi', state: nil, country: 'India', latitude: 28.5665, longitude: 77.1031, is_international: true, hub_tier: 1, timezone: 'Asia/Kolkata', elevation_ft: 777 },
  { code: 'MEL', name: 'Melbourne Airport', city: 'Melbourne', state: nil, country: 'Australia', latitude: -37.6733, longitude: 144.8433, is_international: true, hub_tier: 1, timezone: 'Australia/Melbourne', elevation_ft: 434 },

  # ===== INTERNATIONAL - MIDDLE EAST/AFRICA (4 airports) =====
  { code: 'DXB', name: 'Dubai International', city: 'Dubai', state: nil, country: 'UAE', latitude: 25.2532, longitude: 55.3657, is_international: true, hub_tier: 1, timezone: 'Asia/Dubai', elevation_ft: 62 },
  { code: 'DOH', name: 'Hamad International', city: 'Doha', state: nil, country: 'Qatar', latitude: 25.2731, longitude: 51.6080, is_international: true, hub_tier: 1, timezone: 'Asia/Qatar', elevation_ft: 13 },
  { code: 'CAI', name: 'Cairo International', city: 'Cairo', state: nil, country: 'Egypt', latitude: 30.1219, longitude: 31.4056, is_international: true, hub_tier: 1, timezone: 'Africa/Cairo', elevation_ft: 382 },
  { code: 'JNB', name: 'OR Tambo International', city: 'Johannesburg', state: nil, country: 'South Africa', latitude: -26.1367, longitude: 28.2411, is_international: true, hub_tier: 1, timezone: 'Africa/Johannesburg', elevation_ft: 5558 },

  # ===== INTERNATIONAL - AMERICAS (5 airports) =====
  { code: 'YYZ', name: 'Toronto Pearson', city: 'Toronto', state: nil, country: 'Canada', latitude: 43.6777, longitude: -79.6248, is_international: true, hub_tier: 1, timezone: 'America/Toronto', elevation_ft: 569 },
  { code: 'MEX', name: 'Mexico City International', city: 'Mexico City', state: nil, country: 'Mexico', latitude: 19.4363, longitude: -99.0721, is_international: true, hub_tier: 1, timezone: 'America/Mexico_City', elevation_ft: 7316 },
  { code: 'GRU', name: 'São Paulo-Guarulhos', city: 'São Paulo', state: nil, country: 'Brazil', latitude: -23.4356, longitude: -46.4731, is_international: true, hub_tier: 1, timezone: 'America/Sao_Paulo', elevation_ft: 2459 },
  { code: 'BOG', name: 'El Dorado International', city: 'Bogotá', state: nil, country: 'Colombia', latitude: 4.7016, longitude: -74.1469, is_international: true, hub_tier: 1, timezone: 'America/Bogota', elevation_ft: 8361 },
  { code: 'SCL', name: 'Arturo Merino Benítez International', city: 'Santiago', state: nil, country: 'Chile', latitude: -33.3930, longitude: -70.7858, is_international: true, hub_tier: 1, timezone: 'America/Santiago', elevation_ft: 1555 }
]

airports = {}
airports_data.each do |data|
  airports[data[:code]] = Airport.create!(data)
end
puts "✅ Created #{airports.count} airports"
puts "   - Tier 1 hubs: #{Airport.tier_1_hubs.count}"
puts "   - Tier 2 hubs: #{Airport.tier_2_hubs.count}"
puts "   - Spoke cities: #{Airport.spoke_cities.count}"
puts "   - International: #{Airport.international.count}"

# This file continues in the next message due to length...
puts "\n⚠️  SEED FILE PART 1/2 COMPLETE"
puts "To continue, see seeds_expanded_part2.rb"

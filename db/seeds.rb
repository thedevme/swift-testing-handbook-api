puts "Seeding database..."

# Clear existing data
puts "Clearing existing data..."
Booking.delete_all
Seat.delete_all
Flight.delete_all
Route.delete_all
Aircraft.delete_all
Airport.delete_all

# Aircraft - 7 types with detailed configurations
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
      # Upper deck
      first: { rows: 1..7, columns: %w[A D G K], deck: 'upper', layout: '1-2-1' },
      business: { rows: 8..26, columns: %w[A C D E F G J K], deck: 'upper', layout: '2-4-2' },
      # Main deck
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
puts "Created #{aircraft.count} aircraft"

# Airports
airports_data = [
  # Domestic
  { code: 'TPA', name: 'Tampa International', city: 'Tampa', country: 'USA', latitude: 27.9755, longitude: -82.5332, is_international: false },
  { code: 'JFK', name: 'John F. Kennedy International', city: 'New York', country: 'USA', latitude: 40.6413, longitude: -73.7781, is_international: false },
  { code: 'LAX', name: 'Los Angeles International', city: 'Los Angeles', country: 'USA', latitude: 33.9425, longitude: -118.4081, is_international: false },
  { code: 'ORD', name: "O'Hare International", city: 'Chicago', country: 'USA', latitude: 41.9742, longitude: -87.9073, is_international: false },
  { code: 'BOS', name: 'Logan International', city: 'Boston', country: 'USA', latitude: 42.3656, longitude: -71.0096, is_international: false },
  { code: 'MIA', name: 'Miami International', city: 'Miami', country: 'USA', latitude: 25.7959, longitude: -80.2870, is_international: false },
  { code: 'SEA', name: 'Seattle-Tacoma International', city: 'Seattle', country: 'USA', latitude: 47.4502, longitude: -122.3088, is_international: false },
  { code: 'DEN', name: 'Denver International', city: 'Denver', country: 'USA', latitude: 39.8561, longitude: -104.6737, is_international: false },
  { code: 'ATL', name: 'Hartsfield-Jackson International', city: 'Atlanta', country: 'USA', latitude: 33.6407, longitude: -84.4277, is_international: false },
  { code: 'DFW', name: 'Dallas/Fort Worth International', city: 'Dallas', country: 'USA', latitude: 32.8998, longitude: -97.0403, is_international: false },
  { code: 'LAS', name: 'Harry Reid International', city: 'Las Vegas', country: 'USA', latitude: 36.0840, longitude: -115.1537, is_international: false },
  # International
  { code: 'LHR', name: 'Heathrow', city: 'London', country: 'UK', latitude: 51.4700, longitude: -0.4543, is_international: true },
  { code: 'CDG', name: 'Charles de Gaulle', city: 'Paris', country: 'France', latitude: 49.0097, longitude: 2.5479, is_international: true },
  { code: 'NRT', name: 'Narita International', city: 'Tokyo', country: 'Japan', latitude: 35.7720, longitude: 140.3929, is_international: true },
  { code: 'SYD', name: 'Sydney Kingsford Smith', city: 'Sydney', country: 'Australia', latitude: -33.9399, longitude: 151.1753, is_international: true },
  { code: 'DXB', name: 'Dubai International', city: 'Dubai', country: 'UAE', latitude: 25.2532, longitude: 55.3657, is_international: true },
  { code: 'YYZ', name: 'Toronto Pearson', city: 'Toronto', country: 'Canada', latitude: 43.6777, longitude: -79.6248, is_international: true },
  { code: 'MEX', name: 'Mexico City International', city: 'Mexico City', country: 'Mexico', latitude: 19.4363, longitude: -99.0721, is_international: true },
  { code: 'AMS', name: 'Amsterdam Schiphol', city: 'Amsterdam', country: 'Netherlands', latitude: 52.3105, longitude: 4.7683, is_international: true },
  { code: 'SIN', name: 'Singapore Changi', city: 'Singapore', country: 'Singapore', latitude: 1.3644, longitude: 103.9915, is_international: true },
  { code: 'GRU', name: 'São Paulo-Guarulhos', city: 'São Paulo', country: 'Brazil', latitude: -23.4356, longitude: -46.4731, is_international: true },
  { code: 'DUB', name: 'Dublin Airport', city: 'Dublin', country: 'Ireland', latitude: 53.4264, longitude: -6.2499, is_international: true }
]

airports = {}
airports_data.each do |data|
  airports[data[:code]] = Airport.create!(data)
end
puts "Created #{airports.count} airports"

# Routes with aircraft assignments based on route type
routes_data = [
  # Short Domestic (Boeing 737-800, Airbus A320)
  { origin: 'TPA', destination: 'ATL', duration: 90, departures: 8, prefix: 'DL1', aircraft: 'Boeing 737-800' },
  { origin: 'TPA', destination: 'MIA', duration: 60, departures: 8, prefix: 'DL2', aircraft: 'Airbus A320' },
  { origin: 'TPA', destination: 'ORD', duration: 150, departures: 5, prefix: 'UA3', aircraft: 'Boeing 737-800' },
  { origin: 'TPA', destination: 'JFK', duration: 180, departures: 5, prefix: 'AA4', aircraft: 'Boeing 737-800' },
  { origin: 'TPA', destination: 'DFW', duration: 150, departures: 5, prefix: 'AA5', aircraft: 'Airbus A320' },
  { origin: 'TPA', destination: 'BOS', duration: 180, departures: 4, prefix: 'UA6', aircraft: 'Boeing 737-800' },
  { origin: 'DEN', destination: 'ORD', duration: 150, departures: 5, prefix: 'WN7', aircraft: 'Airbus A320' },
  { origin: 'SEA', destination: 'LAX', duration: 150, departures: 5, prefix: 'AS8', aircraft: 'Airbus A320' },
  { origin: 'DEN', destination: 'LAX', duration: 150, departures: 5, prefix: 'AS9', aircraft: 'Boeing 737-800' },
  { origin: 'ATL', destination: 'ORD', duration: 120, departures: 5, prefix: 'DL10', aircraft: 'Boeing 737-800' },

  # Medium Domestic (Boeing 757-200)
  { origin: 'TPA', destination: 'LAX', duration: 318, departures: 3, prefix: 'UA11', aircraft: 'Boeing 757-200' },
  { origin: 'TPA', destination: 'SEA', duration: 330, departures: 2, prefix: 'UA12', aircraft: 'Boeing 757-200' },
  { origin: 'TPA', destination: 'LAS', duration: 270, departures: 3, prefix: 'DL13', aircraft: 'Boeing 757-200' },
  { origin: 'JFK', destination: 'LAX', duration: 330, departures: 4, prefix: 'AA14', aircraft: 'Boeing 757-200' },
  { origin: 'DFW', destination: 'LAX', duration: 210, departures: 4, prefix: 'AA15', aircraft: 'Boeing 757-200' },
  { origin: 'LAS', destination: 'JFK', duration: 300, departures: 3, prefix: 'DL16', aircraft: 'Boeing 757-200' },
  { origin: 'ORD', destination: 'LAX', duration: 240, departures: 4, prefix: 'UA17', aircraft: 'Boeing 757-200' },
  { origin: 'ATL', destination: 'LAX', duration: 270, departures: 3, prefix: 'DL18', aircraft: 'Boeing 757-200' },

  # Transatlantic (Airbus A330-300) - LHR, CDG, DUB, AMS
  { origin: 'JFK', destination: 'LHR', duration: 420, departures: 3, prefix: 'UA19', aircraft: 'Airbus A330-300', international: true },
  { origin: 'JFK', destination: 'CDG', duration: 450, departures: 3, prefix: 'AF20', aircraft: 'Airbus A330-300', international: true },
  { origin: 'BOS', destination: 'LHR', duration: 390, departures: 3, prefix: 'BA21', aircraft: 'Airbus A330-300', international: true },
  { origin: 'ORD', destination: 'LHR', duration: 510, departures: 3, prefix: 'UA24', aircraft: 'Airbus A330-300', international: true },
  { origin: 'JFK', destination: 'AMS', duration: 430, departures: 2, prefix: 'KL29', aircraft: 'Airbus A330-300', international: true },
  { origin: 'JFK', destination: 'DUB', duration: 390, departures: 2, prefix: 'EI30', aircraft: 'Airbus A330-300', international: true },

  # Heavy International (Boeing 777-200) - NRT, SYD, DXB, GRU, SIN
  { origin: 'LAX', destination: 'NRT', duration: 660, departures: 2, prefix: 'UA26', aircraft: 'Boeing 777-200', international: true },
  { origin: 'SEA', destination: 'NRT', duration: 600, departures: 2, prefix: 'AS27', aircraft: 'Boeing 777-200', international: true },
  { origin: 'LAX', destination: 'SYD', duration: 900, departures: 2, prefix: 'QF28', aircraft: 'Boeing 777-200', international: true },
  { origin: 'MIA', destination: 'GRU', duration: 570, departures: 3, prefix: 'LA25', aircraft: 'Boeing 777-200', international: true },
  { origin: 'LAX', destination: 'SIN', duration: 1080, departures: 1, prefix: 'SQ31', aircraft: 'Boeing 777-200', international: true },

  # JFK → DXB only (Airbus A380-800)
  { origin: 'JFK', destination: 'DXB', duration: 780, departures: 2, prefix: 'EK32', aircraft: 'Airbus A380-800', international: true },

  # Remaining International (Boeing 767-300)
  { origin: 'MIA', destination: 'LHR', duration: 540, departures: 3, prefix: 'VA22', aircraft: 'Boeing 767-300', international: true },
  { origin: 'ATL', destination: 'CDG', duration: 540, departures: 2, prefix: 'AF23', aircraft: 'Boeing 767-300', international: true }
]

routes = []
routes_data.each do |data|
  ac_data = aircraft[data[:aircraft]]
  route = Route.create!(
    origin: airports[data[:origin]],
    destination: airports[data[:destination]],
    aircraft: ac_data[:record],
    duration_minutes: data[:duration],
    departures_per_day: data[:departures],
    flight_number_prefix: data[:prefix],
    is_international: data[:international] || false
  )
  routes << { route: route, aircraft_layout: ac_data[:layout] }
end
puts "Created #{routes.count} routes"

# Helper to determine seat type based on column and layout
def seat_type_for_column(column, layout)
  case layout
  when '2-2'
    %w[A F].include?(column) ? 'window' : 'aisle'
  when '3-3'
    case column
    when 'A', 'F' then 'window'
    when 'B', 'E' then 'middle'
    else 'aisle'
    end
  when '2-3-2'
    case column
    when 'A', 'K' then 'window'
    when 'C', 'G' then 'aisle'
    else 'middle'
    end
  when '2-4-2'
    case column
    when 'A', 'K' then 'window'
    when 'B', 'C', 'G', 'J' then 'aisle'
    else 'middle'
    end
  when '2-2-2'
    case column
    when 'A', 'K' then 'window'
    else 'aisle'
    end
  when '3-3-3'
    case column
    when 'A', 'J' then 'window'
    when 'C', 'D', 'F', 'G' then 'aisle'
    else 'middle'
    end
  when '1-2-1'
    case column
    when 'A', 'K' then 'window'
    else 'aisle'
    end
  when '3-4-3'
    case column
    when 'A', 'K' then 'window'
    when 'C', 'D', 'G', 'H' then 'aisle'
    else 'middle'
    end
  else
    'middle'
  end
end

# Helper to generate features for a seat
def features_for_seat(seat_class, row, is_exit_row = false)
  features = []
  features << 'extra_legroom' if %w[first business comfort_plus].include?(seat_class) || is_exit_row
  features << 'lie_flat' if %w[first business].include?(seat_class)
  features << 'power_outlet' if %w[first business comfort_plus].include?(seat_class)
  features << 'premium_entertainment' if %w[first business].include?(seat_class)
  features
end

# Generate seats for a flight based on aircraft layout
def generate_seats_for_flight(flight, layout)
  seats = []
  now = Time.current

  layout.each do |seat_class, config|
    deck = config[:deck] || 'main'
    section_layout = config[:layout]

    config[:rows].each do |row|
      config[:columns].each do |col|
        seats << {
          flight_id: flight.id,
          seat_number: "#{row}#{col}",
          row: row,
          column_letter: col,
          deck: deck,
          seat_class: seat_class.to_s,
          seat_type: seat_type_for_column(col, section_layout),
          features: features_for_seat(seat_class.to_s, row),
          is_available: true,
          created_at: now,
          updated_at: now
        }
      end
    end
  end

  seats
end

# Create flights for each route
puts "Creating flights and seats..."
flight_count = 0
seat_count = 0

base_date = Date.current

routes.each do |route_data|
  route = route_data[:route]
  layout = route_data[:aircraft_layout]

  (0..6).each do |day_offset|
    date = base_date + day_offset.days

    route.departures_per_day.times do |departure_num|
      hour = (departure_num * 24 / route.departures_per_day) % 24
      minute = [0, 15, 30, 45].sample

      departure_time = date.to_datetime + hour.hours + minute.minutes
      arrival_time = departure_time + route.duration_minutes.minutes

      flight_number = "#{route.flight_number_prefix}#{sprintf('%02d', departure_num)}"

      # Calculate pricing based on route type
      international = route.is_international
      economy_price = (international ? 59900 : 29900) + rand(-5000..5000)
      comfort_price = (international ? 89900 : 44900) + rand(-7500..7500)
      business_price = international ? (149900 + rand(-15000..15000)) : nil
      first_price = international ? nil : (79900 + rand(-10000..10000))

      # A380 and heavy international have premium pricing
      if route.aircraft.model.include?('A380')
        first_price = 299900 + rand(-30000..30000)
        business_price = 199900 + rand(-20000..20000)
      elsif route.aircraft.model.include?('777')
        business_price = 179900 + rand(-18000..18000)
      end

      flight = Flight.create!(
        flight_number: flight_number,
        route: route,
        aircraft: route.aircraft,
        scheduled_departure_at: departure_time,
        scheduled_arrival_at: arrival_time,
        duration_minutes: route.duration_minutes,
        status: ['on_time', 'on_time', 'on_time', 'delayed', 'scheduled'].sample,
        delay_minutes: nil,
        economy_price_cents: economy_price,
        comfort_plus_price_cents: comfort_price,
        business_price_cents: business_price || 0,
        first_price_cents: first_price || 0
      )

      flight.update!(delay_minutes: rand(30..120)) if flight.status == 'delayed'

      # Generate and insert seats
      seats_data = generate_seats_for_flight(flight, layout)
      Seat.insert_all(seats_data) if seats_data.any?
      seat_count += seats_data.count

      flight_count += 1
    end
  end
end

puts "Created #{flight_count} flights"
puts "Created #{seat_count} seats"

# Pre-book some seats randomly
puts "Pre-booking random seats..."
prebooked = 0
Flight.find_each do |flight|
  fill_percentage = rand(0.10..0.35)
  seats_to_fill = (flight.seats.count * fill_percentage).to_i

  flight.seats.order('RANDOM()').limit(seats_to_fill).update_all(is_available: false)
  prebooked += seats_to_fill
end
puts "Pre-booked #{prebooked} seats"

# Ensure at least one flight is cancelled
Flight.where.not(status: 'cancelled').order('RANDOM()').first.update!(status: 'cancelled')
puts "Ensured at least 1 cancelled flight"

puts "\nSeeding complete!"
puts "  #{Aircraft.count} aircraft types"
puts "  #{Airport.count} airports"
puts "  #{Route.count} routes"
puts "  #{Flight.count} flights"
puts "  #{Seat.count} seats"
puts "\nAircraft breakdown:"
Aircraft.all.each do |ac|
  puts "  #{ac.model}: #{ac.total_seats} seats (#{ac.aisle_type} aisle)"
end

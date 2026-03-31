puts "Seeding database..."

# Aircraft
aircraft_data = [
  { model: 'Boeing 737-800', economy_seats: 138, comfort_plus_seats: 14, business_seats: 8, total_seats: 160 },
  { model: 'Airbus A320', economy_seats: 132, comfort_plus_seats: 12, business_seats: 6, total_seats: 150 },
  { model: 'Boeing 767-300', economy_seats: 180, comfort_plus_seats: 21, business_seats: 17, total_seats: 218 }
]

aircraft = aircraft_data.map { |data| Aircraft.find_or_create_by!(model: data[:model]) { |a| a.assign_attributes(data) } }
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
  { code: 'GRU', name: 'São Paulo-Guarulhos', city: 'São Paulo', country: 'Brazil', latitude: -23.4356, longitude: -46.4731, is_international: true }
]

airports = {}
airports_data.each do |data|
  airports[data[:code]] = Airport.find_or_create_by!(code: data[:code]) { |a| a.assign_attributes(data) }
end
puts "Created #{airports.count} airports"

# Routes
boeing_737 = Aircraft.find_by!(model: 'Boeing 737-800')
airbus_a320 = Aircraft.find_by!(model: 'Airbus A320')
boeing_767 = Aircraft.find_by!(model: 'Boeing 767-300')

routes_data = [
  # Domestic Short-Haul
  { origin: 'TPA', destination: 'ATL', duration: 90, departures: 8, prefix: 'DL1', aircraft: boeing_737 },
  { origin: 'TPA', destination: 'MIA', duration: 60, departures: 8, prefix: 'DL2', aircraft: airbus_a320 },
  { origin: 'TPA', destination: 'ORD', duration: 150, departures: 5, prefix: 'UA3', aircraft: boeing_737 },
  { origin: 'TPA', destination: 'JFK', duration: 180, departures: 5, prefix: 'AA4', aircraft: boeing_737 },
  { origin: 'TPA', destination: 'DFW', duration: 150, departures: 5, prefix: 'AA5', aircraft: boeing_737 },
  { origin: 'TPA', destination: 'BOS', duration: 180, departures: 4, prefix: 'UA6', aircraft: boeing_737 },
  { origin: 'DEN', destination: 'ORD', duration: 150, departures: 5, prefix: 'WN7', aircraft: airbus_a320 },
  { origin: 'SEA', destination: 'LAX', duration: 150, departures: 5, prefix: 'AS8', aircraft: airbus_a320 },
  { origin: 'DEN', destination: 'LAX', duration: 150, departures: 5, prefix: 'AS9', aircraft: airbus_a320 },
  { origin: 'ATL', destination: 'ORD', duration: 120, departures: 5, prefix: 'DL10', aircraft: boeing_737 },
  # Domestic Medium-Haul
  { origin: 'TPA', destination: 'LAX', duration: 318, departures: 3, prefix: 'UA11', aircraft: boeing_737 },
  { origin: 'TPA', destination: 'SEA', duration: 330, departures: 2, prefix: 'UA12', aircraft: boeing_737 },
  { origin: 'TPA', destination: 'LAS', duration: 270, departures: 3, prefix: 'DL13', aircraft: boeing_737 },
  { origin: 'JFK', destination: 'LAX', duration: 330, departures: 4, prefix: 'AA14', aircraft: boeing_737 },
  { origin: 'DFW', destination: 'LAX', duration: 210, departures: 4, prefix: 'AA15', aircraft: boeing_737 },
  { origin: 'LAS', destination: 'JFK', duration: 300, departures: 3, prefix: 'DL16', aircraft: boeing_737 },
  { origin: 'ORD', destination: 'LAX', duration: 240, departures: 4, prefix: 'UA17', aircraft: boeing_737 },
  { origin: 'ATL', destination: 'LAX', duration: 270, departures: 3, prefix: 'DL18', aircraft: boeing_737 },
  # International Long-Haul
  { origin: 'JFK', destination: 'LHR', duration: 420, departures: 3, prefix: 'UA19', aircraft: boeing_767, international: true },
  { origin: 'JFK', destination: 'CDG', duration: 450, departures: 3, prefix: 'AF20', aircraft: boeing_767, international: true },
  { origin: 'BOS', destination: 'LHR', duration: 390, departures: 3, prefix: 'BA21', aircraft: boeing_767, international: true },
  { origin: 'MIA', destination: 'LHR', duration: 540, departures: 3, prefix: 'VA22', aircraft: boeing_767, international: true },
  { origin: 'ATL', destination: 'CDG', duration: 540, departures: 2, prefix: 'AF23', aircraft: boeing_767, international: true },
  { origin: 'ORD', destination: 'LHR', duration: 510, departures: 3, prefix: 'UA24', aircraft: boeing_767, international: true },
  { origin: 'MIA', destination: 'GRU', duration: 570, departures: 3, prefix: 'LA25', aircraft: boeing_767, international: true },
  { origin: 'LAX', destination: 'NRT', duration: 660, departures: 2, prefix: 'UA26', aircraft: boeing_767, international: true },
  { origin: 'SEA', destination: 'NRT', duration: 600, departures: 2, prefix: 'AS27', aircraft: boeing_767, international: true },
  { origin: 'LAX', destination: 'SYD', duration: 900, departures: 2, prefix: 'QF28', aircraft: boeing_767, international: true }
]

routes = []
routes_data.each do |data|
  route = Route.find_or_create_by!(
    origin: airports[data[:origin]],
    destination: airports[data[:destination]]
  ) do |r|
    r.aircraft = data[:aircraft]
    r.duration_minutes = data[:duration]
    r.departures_per_day = data[:departures]
    r.flight_number_prefix = data[:prefix]
    r.is_international = data[:international] || false
  end
  routes << route
end
puts "Created #{routes.count} routes"

# Generate seat map for a flight
def generate_seats(flight, aircraft)
  seats = []
  row = 1

  # Business class
  aircraft.business_seats.times do |i|
    seat_letter = ['A', 'C', 'D', 'F'][i % 4]
    if i % 4 == 0 && i > 0
      row += 1
    end
    seats << {
      flight_id: flight.id,
      seat_number: "#{row}#{seat_letter}",
      seat_class: 'business',
      seat_type: ['A', 'F'].include?(seat_letter) ? 'window' : 'aisle',
      features: ['extra_legroom', 'lie_flat'],
      is_available: true,
      created_at: Time.current,
      updated_at: Time.current
    }
  end
  row += 1

  # Comfort+ class
  aircraft.comfort_plus_seats.times do |i|
    seat_letter = ['A', 'B', 'C', 'D', 'E', 'F'][i % 6]
    if i % 6 == 0 && i > 0
      row += 1
    end
    seats << {
      flight_id: flight.id,
      seat_number: "#{row}#{seat_letter}",
      seat_class: 'comfort_plus',
      seat_type: case seat_letter
                 when 'A', 'F' then 'window'
                 when 'B', 'E' then 'middle'
                 else 'aisle'
                 end,
      features: ['extra_legroom'],
      is_available: true,
      created_at: Time.current,
      updated_at: Time.current
    }
  end
  row += 1

  # Economy class
  aircraft.economy_seats.times do |i|
    seat_letter = ['A', 'B', 'C', 'D', 'E', 'F'][i % 6]
    if i % 6 == 0 && i > 0
      row += 1
    end
    seats << {
      flight_id: flight.id,
      seat_number: "#{row}#{seat_letter}",
      seat_class: 'economy',
      seat_type: case seat_letter
                 when 'A', 'F' then 'window'
                 when 'B', 'E' then 'middle'
                 else 'aisle'
                 end,
      features: [],
      is_available: true,
      created_at: Time.current,
      updated_at: Time.current
    }
  end

  seats
end

# Create flights for each route
puts "Creating flights and seats..."
flight_count = 0
seat_count = 0

# Generate flights for the next 7 days
base_date = Date.current

routes.each do |route|
  (0..6).each do |day_offset|
    date = base_date + day_offset.days

    route.departures_per_day.times do |departure_num|
      # Spread departures throughout the day
      hour = (departure_num * 24 / route.departures_per_day) % 24
      minute = [0, 15, 30, 45].sample

      departure_time = date.to_datetime + hour.hours + minute.minutes
      arrival_time = departure_time + route.duration_minutes.minutes

      flight_number = "#{route.flight_number_prefix}#{sprintf('%02d', departure_num)}"

      # Calculate pricing
      international = route.is_international
      economy_price = (international ? 59900 : 29900) + rand(-5000..5000)
      comfort_price = (international ? 89900 : 44900) + rand(-7500..7500)
      business_price = (international ? 249900 : 89900) + rand(-15000..15000)

      flight = Flight.find_or_create_by!(
        flight_number: flight_number,
        scheduled_departure_at: departure_time
      ) do |f|
        f.route = route
        f.aircraft = route.aircraft
        f.scheduled_arrival_at = arrival_time
        f.duration_minutes = route.duration_minutes
        f.status = ['on_time', 'on_time', 'on_time', 'delayed', 'scheduled'].sample
        f.delay_minutes = f.status == 'delayed' ? rand(30..120) : nil
        f.economy_price_cents = economy_price
        f.comfort_plus_price_cents = comfort_price
        f.business_price_cents = business_price
      end

      # Create seats if they don't exist
      if flight.seats.empty?
        seats_data = generate_seats(flight, route.aircraft)
        Seat.insert_all(seats_data)
        seat_count += seats_data.count
      end

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
puts "  #{Aircraft.count} aircraft"
puts "  #{Airport.count} airports"
puts "  #{Route.count} routes"
puts "  #{Flight.count} flights"
puts "  #{Seat.count} seats"

# SEED FILE PART 2 - Route Generation & Flights
# This continues from seeds_expanded.rb

# =======================
# HELPER METHODS
# =======================

# Calculate approximate distance between two airports in miles
def distance_between(airport1, airport2)
  lat_diff = (airport1.latitude - airport2.latitude).abs
  lng_diff = (airport1.longitude - airport2.longitude).abs
  distance_degrees = Math.sqrt(lat_diff**2 + lng_diff**2)
  (distance_degrees * 69).round # 1 degree ≈ 69 miles
end

# Select appropriate aircraft based on distance and route type
def aircraft_for_distance(distance, international, aircraft_hash)
  model = case
  when distance < 500 then 'Airbus A320'
  when distance < 1500 then 'Boeing 737-800'
  when distance < 2500 then 'Boeing 757-200'
  when distance < 4000 then 'Airbus A330-300'
  when distance < 8000 then 'Boeing 777-200'
  else
    international ? 'Airbus A380-800' : 'Boeing 777-200'
  end
  aircraft_hash[model]
end

# Find nearest hub for a spoke city
def nearest_hub(origin_airport, hubs)
  hubs.min_by { |hub| distance_between(origin_airport, hub) }
end

# Determine seat type based on column and layout
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
    %w[A K].include?(column) ? 'window' : 'aisle'
  when '3-3-3'
    case column
    when 'A', 'J' then 'window'
    when 'C', 'D', 'F', 'G' then 'aisle'
    else 'middle'
    end
  when '1-2-1'
    %w[A K].include?(column) ? 'window' : 'aisle'
  when '3-4-3'
    case column
    when 'A', 'K' then 'window'
    when 'C', 'D', 'G', 'H' then 'aisle'
    else 'middle'
    end
  else 'middle'
  end
end

# Generate seat features
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

# =======================
# ROUTE GENERATION
# =======================
puts "\n🛫 Generating intelligent route network..."

tier_1_hubs = Airport.tier_1_hubs.domestic.to_a
tier_2_hubs = Airport.tier_2_hubs.domestic.to_a
spoke_cities = Airport.spoke_cities.domestic.to_a
international_gateways_codes = ['JFK', 'LAX', 'SFO', 'ORD', 'ATL', 'MIA', 'IAH', 'DFW', 'EWR', 'BOS']
all_international = Airport.international.to_a

route_count = 0
routes = []

# 1. TIER 1 HUB TO HUB ROUTES
puts "  Creating Tier 1 hub-to-hub routes..."
tier_1_hubs.each do |origin|
  tier_1_hubs.each do |destination|
    next if origin == destination

    # Don't duplicate reverse routes
    existing = routes.any? { |r| r[:origin] == destination.code && r[:destination] == origin.code }
    next if existing

    distance = distance_between(origin, destination)
    aircraft_data = aircraft_for_distance(distance, false, aircraft)
    departures = distance < 1000 ? 5 : (distance < 2000 ? 3 : 2)

    route = Route.create!(
      origin: origin,
      destination: destination,
      aircraft: aircraft_data[:record],
      duration_minutes: (distance / 8.0).round,
      departures_per_day: departures,
      flight_number_prefix: "#{['UA', 'AA', 'DL', 'WN'].sample}#{rand(10..99)}",
      is_international: false
    )
    routes << { route: route, aircraft_layout: aircraft_data[:layout], origin: origin.code, destination: destination.code }
    route_count += 1
  end
end
puts "  ✅ Created #{route_count} Tier 1 hub routes"

# 2. TIER 2 TO TIER 1 HUB ROUTES
puts "  Creating Tier 2 to Tier 1 hub routes..."
tier_2_hubs.each do |origin|
  nearest_hubs = tier_1_hubs.sort_by { |h| distance_between(origin, h) }.take(3)

  nearest_hubs.each do |destination|
    distance = distance_between(origin, destination)
    aircraft_data = aircraft_for_distance(distance, false, aircraft)

    route = Route.create!(
      origin: origin,
      destination: destination,
      aircraft: aircraft_data[:record],
      duration_minutes: (distance / 8.0).round,
      departures_per_day: 3,
      flight_number_prefix: "#{['UA', 'AA', 'DL'].sample}#{rand(10..99)}",
      is_international: false
    )
    routes << { route: route, aircraft_layout: aircraft_data[:layout], origin: origin.code, destination: destination.code }
    route_count += 1
  end
end
puts "  ✅ Total routes: #{route_count}"

# 3. SPOKE TO NEAREST HUB
puts "  Creating spoke to hub routes..."
all_hubs = tier_1_hubs + tier_2_hubs
spoke_cities.each do |origin|
  hub = nearest_hub(origin, all_hubs)
  distance = distance_between(origin, hub)
  aircraft_data = aircraft_for_distance(distance, false, aircraft)

  route = Route.create!(
    origin: origin,
    destination: hub,
    aircraft: aircraft_data[:record],
    duration_minutes: (distance / 8.0).round,
    departures_per_day: 2,
    flight_number_prefix: "#{['UA', 'AA', 'DL', 'WN'].sample}#{rand(10..99)}",
    is_international: false
  )
  routes << { route: route, aircraft_layout: aircraft_data[:layout], origin: origin.code, destination: hub.code }
  route_count += 1
end
puts "  ✅ Total routes: #{route_count}"

# 4. INTERNATIONAL ROUTES
puts "  Creating international routes..."
gateways = Airport.where(code: international_gateways_codes).to_a
all_international.each do |intl_city|
  num_gateways = case intl_city.code
  when 'LHR', 'CDG', 'NRT', 'HKG', 'SYD' then 5
  when 'FRA', 'AMS', 'DXB', 'SIN' then 3
  else 2
  end

  gateways.sample(num_gateways).each do |gateway|
    distance = distance_between(gateway, intl_city)
    aircraft_data = aircraft_for_distance(distance, true, aircraft)

    route = Route.create!(
      origin: gateway,
      destination: intl_city,
      aircraft: aircraft_data[:record],
      duration_minutes: (distance / 8.0).round,
      departures_per_day: rand(1..3),
      flight_number_prefix: "#{['UA', 'AA', 'DL', 'BA', 'AF', 'LH'].sample}#{rand(10..99)}",
      is_international: true
    )
    routes << { route: route, aircraft_layout: aircraft_data[:layout], origin: gateway.code, destination: intl_city.code }
    route_count += 1
  end
end

puts "✅ Created #{route_count} total routes"

# =======================
# FLIGHTS & SEATS
# =======================
puts "\n✈️  Creating flights and seats for next 7 days..."
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

      # Pricing based on route type
      international = route.is_international
      economy_price = (international ? 59900 : 29900) + rand(-5000..5000)
      comfort_price = (international ? 89900 : 44900) + rand(-7500..7500)
      business_price = international ? (149900 + rand(-15000..15000)) : nil
      first_price = international ? nil : (79900 + rand(-10000..10000))

      # A380 premium pricing
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

      # Generate seats
      seats_data = generate_seats_for_flight(flight, layout)
      Seat.insert_all(seats_data) if seats_data.any?
      seat_count += seats_data.count

      flight_count += 1
    end
  end

  # Progress indicator
  print "." if route_count % 20 == 0
end

puts "\n✅ Created #{flight_count} flights"
puts "✅ Created #{seat_count} seats"

# =======================
# PRE-BOOK RANDOM SEATS
# =======================
puts "\n💺 Pre-booking random seats..."
prebooked = 0
Flight.find_each do |flight|
  fill_percentage = rand(0.10..0.35)
  seats_to_fill = (flight.seats.count * fill_percentage).to_i

  flight.seats.order('RANDOM()').limit(seats_to_fill).update_all(is_available: false)
  prebooked += seats_to_fill
end
puts "✅ Pre-booked #{prebooked} seats"

# Ensure at least one flight is cancelled
Flight.where.not(status: 'cancelled').order('RANDOM()').first&.update!(status: 'cancelled')
puts "✅ Ensured at least 1 cancelled flight"

# =======================
# GENERATE WEATHER
# =======================
puts "\n🌤️  Generating 7-day weather forecast for all airports..."
WeatherCondition.generate_forecasts(7)
puts "✅ Generated weather for #{Airport.count} airports × 7 days"

# =======================
# SUMMARY
# =======================
puts "\n" + "=" * 80
puts "SEED COMPLETE! 🎉"
puts "=" * 80
puts "Aircraft types: #{Aircraft.count}"
puts "Airports: #{Airport.count} (#{Airport.domestic.count} domestic, #{Airport.international.count} international)"
puts "Routes: #{Route.count}"
puts "Flights: #{Flight.count} (next 7 days)"
puts "Seats: #{Seat.count}"
puts "Weather forecasts: #{WeatherCondition.count}"
puts ""
puts "Hub breakdown:"
puts "  Tier 1 major hubs: #{Airport.tier_1_hubs.count}"
puts "  Tier 2 regional hubs: #{Airport.tier_2_hubs.count}"
puts "  Tier 3 spoke cities: #{Airport.spoke_cities.count}"
puts ""
puts "Aircraft distribution:"
Aircraft.all.each do |ac|
  flight_count = Flight.where(aircraft: ac).count
  puts "  #{ac.model}: #{flight_count} flights, #{ac.total_seats} seats each"
end
puts "=" * 80

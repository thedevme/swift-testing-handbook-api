# AIRLINES SEED FILE
# Run with: rails runner "load 'db/seeds_airlines.rb'"

puts "\n" + "=" * 80
puts "SEEDING 12 AIRLINES"
puts "=" * 80

airlines_data = [
  {
    code: 'AX',
    name: 'Aerolux',
    country: 'USA',
    airline_type: 'legacy',
    logo_svg: '01_aerolux.svg',
    logo_png: '01_aerolux@3x.png'
  },
  {
    code: 'NB',
    name: 'Nimbus Air',
    country: 'USA',
    airline_type: 'low_cost',
    logo_svg: '02_nimbus.svg',
    logo_png: '02_nimbus@3x.png'
  },
  {
    code: 'SB',
    name: 'SKYBOUND',
    country: 'USA',
    airline_type: 'low_cost',
    logo_svg: '03_skybound.svg',
    logo_png: '03_skybound@3x.png'
  },
  {
    code: 'VX',
    name: 'VERTEX',
    country: 'USA',
    airline_type: 'regional',
    logo_svg: '04_vertex.svg',
    logo_png: '04_vertex@3x.png'
  },
  {
    code: 'PL',
    name: 'Polaris',
    country: 'USA',
    airline_type: 'legacy',
    logo_svg: '05_polaris.svg',
    logo_png: '05_polaris@3x.png'
  },
  {
    code: 'ZP',
    name: 'Zephyr',
    country: 'USA',
    airline_type: 'low_cost',
    logo_svg: '06_zephyr.svg',
    logo_png: '06_zephyr@3x.png'
  },
  {
    code: 'AL',
    name: 'ALTAIR',
    country: 'USA',
    airline_type: 'legacy',
    logo_svg: '07_altair.svg',
    logo_png: '07_altair@3x.png'
  },
  {
    code: 'MD',
    name: 'Meridian',
    country: 'USA',
    airline_type: 'legacy',
    logo_svg: '08_meridian.svg',
    logo_png: '08_meridian@3x.png'
  },
  {
    code: 'ST',
    name: 'Solstice',
    country: 'USA',
    airline_type: 'low_cost',
    logo_svg: '09_solstice.svg',
    logo_png: '09_solstice@3x.png'
  },
  {
    code: 'CS',
    name: 'Cascade',
    country: 'USA',
    airline_type: 'regional',
    logo_svg: '10_cascade.svg',
    logo_png: '10_cascade@3x.png'
  },
  {
    code: 'NW',
    name: 'NORTHWIND',
    country: 'USA',
    airline_type: 'regional',
    logo_svg: '11_northwind.svg',
    logo_png: '11_northwind@3x.png'
  },
  {
    code: 'AR',
    name: 'Aurora',
    country: 'USA',
    airline_type: 'legacy',
    logo_svg: '12_aurora.svg',
    logo_png: '12_aurora@3x.png'
  }
]

puts "\n✈️  Creating #{airlines_data.count} airlines..."

airlines_data.each do |data|
  airline = Airline.find_or_create_by!(code: data[:code]) do |a|
    a.name = data[:name]
    a.country = data[:country]
    a.airline_type = data[:airline_type]
    a.logo_svg = data[:logo_svg]
    a.logo_png = data[:logo_png]
  end
  puts "  ✅ #{airline.code} - #{airline.name}"
end

puts "\n✅ Created #{Airline.count} airlines total"

# Update existing routes to randomly assign airlines
puts "\n🔄 Assigning airlines to existing routes..."

routes = Route.all
airlines = Airline.all.to_a

routes.each do |route|
  # Assign airline based on route type
  if route.is_international
    # International routes get legacy carriers
    airline = airlines.select { |a| a.airline_type == 'legacy' }.sample
  elsif route.duration_minutes > 180
    # Long domestic routes get legacy or low-cost
    airline = airlines.select { |a| ['legacy', 'low_cost'].include?(a.airline_type) }.sample
  else
    # Short routes can be any type
    airline = airlines.sample
  end

  route.update!(airline: airline)

  # Update flight number prefix to match airline code
  route.update!(flight_number_prefix: "#{airline.code}#{rand(10..99)}")
end

puts "✅ Updated #{Route.count} routes with airlines"

# Update existing flights to reflect new airline codes
puts "\n🔄 Updating flight numbers..."
Flight.find_each do |flight|
  if flight.route.airline
    old_number = flight.flight_number
    # Extract the numeric part (last 2 digits)
    number_suffix = old_number.scan(/\d+$/).first || sprintf('%02d', rand(0..99))
    new_number = "#{flight.route.airline.code}#{number_suffix}"
    flight.update!(flight_number: new_number)
  end
end

puts "✅ Updated flight numbers"

puts "\n" + "=" * 80
puts "AIRLINES SEED COMPLETE! 🎉"
puts "=" * 80
puts "Total airlines: #{Airline.count}"
puts ""
puts "Breakdown by type:"
puts "  Legacy carriers: #{Airline.where(airline_type: 'legacy').count}"
puts "  Low-cost carriers: #{Airline.where(airline_type: 'low_cost').count}"
puts "  Regional carriers: #{Airline.where(airline_type: 'regional').count}"
puts "=" * 80

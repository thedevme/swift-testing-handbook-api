namespace :phase0 do
  desc "Run Phase 0: Expand to 70 cities with weather"
  task setup: :environment do
    puts "\n" + "=" * 80
    puts "PHASE 0: CITY EXPANSION & WEATHER"
    puts "=" * 80
    puts "\n📋 Running migrations..."

    # Run migrations
    Rake::Task['db:migrate'].invoke

    puts "✅ Migrations complete\n"
  end

  desc "Seed expanded data (70 cities + weather)"
  task seed: :environment do
    # Load and execute both seed file parts
    puts "\n🌱 Loading expanded seed data..."

    load Rails.root.join('db', 'seeds_expanded.rb')
    load Rails.root.join('db', 'seeds_expanded_part2.rb')

    puts "\n✅ Phase 0 seed complete!"
  end

  desc "Complete Phase 0 setup (migrate + seed)"
  task run: [:setup, :seed] do
    puts "\n" + "=" * 80
    puts "PHASE 0 COMPLETE! 🎉"
    puts "=" * 80
    puts "\nYou now have:"
    puts "  ✅ 70 airports (40 US + 30 international)"
    puts "  ✅ ~274 intelligent routes (hub-and-spoke)"
    puts "  ✅ Weather forecasts for all cities"
    puts "  ✅ Flights for next 7 days"
    puts "  ✅ Real-time weather in flight API responses"
    puts "\nNext steps:"
    puts "  rails server  # Start the API"
    puts "  # Test weather: GET /api/v1/weather?airport=TPA"
    puts "  # Test flights with weather: GET /api/v1/flights"
    puts "=" * 80
  end

  desc "Quick test - show city and route counts"
  task stats: :environment do
    puts "\n📊 Phase 0 Statistics:"
    puts "  Airports: #{Airport.count}"
    puts "    - Domestic: #{Airport.domestic.count}"
    puts "    - International: #{Airport.international.count}"
    puts "    - Tier 1 hubs: #{Airport.tier_1_hubs.count}"
    puts "    - Tier 2 hubs: #{Airport.tier_2_hubs.count}"
    puts "    - Spoke cities: #{Airport.spoke_cities.count}"
    puts "  Routes: #{Route.count}"
    puts "  Flights: #{Flight.count}"
    puts "  Seats: #{Seat.count}"
    puts "  Weather forecasts: #{WeatherCondition.count}"
    puts ""
  end
end

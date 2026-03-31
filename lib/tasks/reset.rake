namespace :api do
  desc "Daily flight status reset — runs every day at midnight UTC"
  task daily_reset: :environment do
    puts "Daily reset starting at #{Time.current.utc}"

    ActiveRecord::Base.transaction do
      Flight.find_each do |flight|
        status = weighted_random_status
        delay = status == 'delayed' ? rand(30..240) : nil
        diverted_to = status == 'diverted' ? nearby_airport(flight.destination.code) : nil

        flight.update!(
          status: status,
          delay_minutes: delay,
          diverted_to: diverted_to
        )
      end

      # Guarantee at least 1 cancellation
      if Flight.cancelled.count.zero?
        Flight.order('RANDOM()').first&.update!(status: 'cancelled')
      end
    end

    puts "Daily reset complete — #{Flight.group(:status).count}"
  end

  desc "Weekly seat and pricing reset — runs every Sunday midnight UTC"
  task weekly_reset: :environment do
    puts "Weekly reset starting at #{Time.current.utc}"

    ActiveRecord::Base.transaction do
      # Clear all bookings
      Booking.delete_all

      # Reset all seats to available
      Seat.update_all(is_available: true)

      # Pre-book random seats per flight
      Flight.bookable.find_each do |flight|
        seats = flight.seats.order('RANDOM()')
        fill_count = (seats.count * rand(0.10..0.40)).to_i
        seats.limit(fill_count).update_all(is_available: false)
      end

      # Randomize pricing
      Flight.find_each do |flight|
        international = flight.route.is_international

        flight.update!(
          economy_price_cents: base_economy(international) + rand(-5000..5000),
          comfort_plus_price_cents: base_comfort(international) + rand(-7500..7500),
          business_price_cents: base_business(international) + rand(-15000..15000)
        )
      end
    end

    puts "Weekly reset complete at #{Time.current.utc}"
  end

  private

  def weighted_random_status
    roll = rand(100)
    case
    when roll < 55 then 'on_time'
    when roll < 80 then 'delayed'
    when roll < 90 then 'scheduled'
    when roll < 98 then 'cancelled'
    else 'diverted'
    end
  end

  def nearby_airport(code)
    nearby = {
      'JFK' => 'LGA', 'LHR' => 'LGW', 'NRT' => 'HND',
      'LAX' => 'BUR', 'ORD' => 'MDW', 'SFO' => 'OAK'
    }
    nearby[code] || code
  end

  def base_economy(international)
    international ? 59900 : 29900
  end

  def base_comfort(international)
    international ? 89900 : 44900
  end

  def base_business(international)
    international ? 249900 : 89900
  end
end

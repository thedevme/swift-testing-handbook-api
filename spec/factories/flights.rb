FactoryBot.define do
  factory :flight do
    association :route
    association :aircraft

    sequence(:flight_number) { |n| "SK#{format('%04d', n)}" }
    scheduled_departure_at { 2.hours.from_now }
    scheduled_arrival_at { 5.hours.from_now }
    duration_minutes { 180 }
    economy_price_cents { 15000 }
    comfort_plus_price_cents { 25000 }
    business_price_cents { 45000 }
    first_price_cents { nil }
    status { 'scheduled' }
    delay_minutes { nil }
    diverted_to { nil }

    trait :scheduled do
      status { 'scheduled' }
    end

    trait :on_time do
      status { 'on_time' }
    end

    trait :delayed do
      status { 'delayed' }
      delay_minutes { 30 }
    end

    trait :boarding do
      status { 'boarding' }
      scheduled_departure_at { 15.minutes.from_now }
      scheduled_arrival_at { 3.hours.from_now }
    end

    trait :departed do
      status { 'departed' }
      scheduled_departure_at { 1.hour.ago }
      scheduled_arrival_at { 2.hours.from_now }
    end

    trait :arrived do
      status { 'arrived' }
      scheduled_departure_at { 5.hours.ago }
      scheduled_arrival_at { 2.hours.ago }
    end

    trait :cancelled do
      status { 'cancelled' }
    end

    trait :diverted do
      status { 'diverted' }
      diverted_to { 'BOS' }
    end

    trait :in_air do
      status { 'departed' }
      scheduled_departure_at { 1.hour.ago }
      scheduled_arrival_at { 2.hours.from_now }
    end

    trait :cheap do
      economy_price_cents { 9900 }
      comfort_plus_price_cents { 14900 }
      business_price_cents { 24900 }
    end

    trait :expensive do
      economy_price_cents { 49900 }
      comfort_plus_price_cents { 79900 }
      business_price_cents { 149900 }
      first_price_cents { 299900 }
    end

    trait :with_first_class do
      first_price_cents { 75000 }
    end

    trait :domestic do
      business_price_cents { 0 }
      first_price_cents { 45000 }
    end

    trait :international do
      business_price_cents { 120000 }
      first_price_cents { nil }
    end

    trait :tomorrow do
      scheduled_departure_at { 1.day.from_now.beginning_of_day + 8.hours }
      scheduled_arrival_at { 1.day.from_now.beginning_of_day + 11.hours }
    end

    trait :yesterday do
      scheduled_departure_at { 1.day.ago.beginning_of_day + 8.hours }
      scheduled_arrival_at { 1.day.ago.beginning_of_day + 11.hours }
      status { 'arrived' }
    end

    trait :with_seats do
      after(:create) do |flight|
        # Create some economy seats
        6.times do |row|
          %w[A B C D E F].each_with_index do |col, idx|
            seat_type = case idx
                        when 0, 5 then 'window'
                        when 1, 4 then 'middle'
                        else 'aisle'
                        end

            create(:seat,
                   flight: flight,
                   seat_number: "#{row + 10}#{col}",
                   row: row + 10,
                   column_letter: col,
                   seat_class: 'economy',
                   seat_type: seat_type)
          end
        end

        # Create some comfort plus seats
        2.times do |row|
          %w[A B C D E F].each_with_index do |col, idx|
            seat_type = case idx
                        when 0, 5 then 'window'
                        when 1, 4 then 'middle'
                        else 'aisle'
                        end

            create(:seat,
                   flight: flight,
                   seat_number: "#{row + 5}#{col}",
                   row: row + 5,
                   column_letter: col,
                   seat_class: 'comfort_plus',
                   seat_type: seat_type)
          end
        end

        # Create some business seats
        2.times do |row|
          %w[A C D F].each_with_index do |col, idx|
            seat_type = idx.even? ? 'window' : 'aisle'

            create(:seat,
                   flight: flight,
                   seat_number: "#{row + 1}#{col}",
                   row: row + 1,
                   column_letter: col,
                   seat_class: 'business',
                   seat_type: seat_type)
          end
        end
      end
    end
  end
end

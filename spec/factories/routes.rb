FactoryBot.define do
  factory :route do
    association :origin, factory: :airport
    association :destination, factory: :airport
    association :aircraft

    duration_minutes { 180 }
    departures_per_day { 4 }
    sequence(:flight_number_prefix) { |n| "SK#{format('%02d', n % 100)}" }
    is_international { false }

    trait :domestic do
      is_international { false }
      duration_minutes { 150 }
    end

    trait :international do
      is_international { true }
      duration_minutes { 480 }
    end

    trait :short_haul do
      duration_minutes { 90 }
    end

    trait :long_haul do
      duration_minutes { 720 }
    end

    trait :tpa_to_jfk do
      association :origin, factory: [:airport, :tpa]
      association :destination, factory: [:airport, :jfk]
      flight_number_prefix { 'SK10' }
      duration_minutes { 165 }
      is_international { false }
    end

    trait :jfk_to_lhr do
      association :origin, factory: [:airport, :jfk]
      association :destination, factory: [:airport, :lhr]
      flight_number_prefix { 'SK20' }
      duration_minutes { 435 }
      is_international { true }
    end
  end
end

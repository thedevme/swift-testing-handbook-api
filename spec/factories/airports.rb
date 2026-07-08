FactoryBot.define do
  factory :airport do
    sequence(:code) { |n| "X#{format('%02d', n % 100)}" }
    name { "#{Faker::Address.city} International Airport" }
    city { Faker::Address.city }
    country { Faker::Address.country }
    latitude { Faker::Address.latitude }
    longitude { Faker::Address.longitude }
    is_international { false }

    # US Domestic Airports
    trait :tpa do
      code { 'TPA' }
      name { 'Tampa International Airport' }
      city { 'Tampa' }
      country { 'United States' }
      latitude { 27.9755 }
      longitude { -82.5332 }
      is_international { false }
    end

    trait :jfk do
      code { 'JFK' }
      name { 'John F. Kennedy International Airport' }
      city { 'New York' }
      country { 'United States' }
      latitude { 40.6413 }
      longitude { -73.7781 }
      is_international { true }
    end

    trait :lax do
      code { 'LAX' }
      name { 'Los Angeles International Airport' }
      city { 'Los Angeles' }
      country { 'United States' }
      latitude { 33.9425 }
      longitude { -118.4081 }
      is_international { true }
    end

    trait :ord do
      code { 'ORD' }
      name { "O'Hare International Airport" }
      city { 'Chicago' }
      country { 'United States' }
      latitude { 41.9742 }
      longitude { -87.9073 }
      is_international { true }
    end

    trait :bos do
      code { 'BOS' }
      name { 'Logan International Airport' }
      city { 'Boston' }
      country { 'United States' }
      latitude { 42.3656 }
      longitude { -71.0096 }
      is_international { false }
    end

    trait :mia do
      code { 'MIA' }
      name { 'Miami International Airport' }
      city { 'Miami' }
      country { 'United States' }
      latitude { 25.7959 }
      longitude { -80.2870 }
      is_international { true }
    end

    trait :sea do
      code { 'SEA' }
      name { 'Seattle-Tacoma International Airport' }
      city { 'Seattle' }
      country { 'United States' }
      latitude { 47.4502 }
      longitude { -122.3088 }
      is_international { false }
    end

    trait :den do
      code { 'DEN' }
      name { 'Denver International Airport' }
      city { 'Denver' }
      country { 'United States' }
      latitude { 39.8561 }
      longitude { -104.6737 }
      is_international { false }
    end

    trait :atl do
      code { 'ATL' }
      name { 'Hartsfield-Jackson Atlanta International Airport' }
      city { 'Atlanta' }
      country { 'United States' }
      latitude { 33.6407 }
      longitude { -84.4277 }
      is_international { true }
    end

    trait :dfw do
      code { 'DFW' }
      name { 'Dallas/Fort Worth International Airport' }
      city { 'Dallas' }
      country { 'United States' }
      latitude { 32.8998 }
      longitude { -97.0403 }
      is_international { false }
    end

    # International Airports
    trait :lhr do
      code { 'LHR' }
      name { 'London Heathrow Airport' }
      city { 'London' }
      country { 'United Kingdom' }
      latitude { 51.4700 }
      longitude { -0.4543 }
      is_international { true }
    end

    trait :cdg do
      code { 'CDG' }
      name { 'Charles de Gaulle Airport' }
      city { 'Paris' }
      country { 'France' }
      latitude { 49.0097 }
      longitude { 2.5479 }
      is_international { true }
    end

    trait :nrt do
      code { 'NRT' }
      name { 'Narita International Airport' }
      city { 'Tokyo' }
      country { 'Japan' }
      latitude { 35.7720 }
      longitude { 140.3929 }
      is_international { true }
    end

    trait :syd do
      code { 'SYD' }
      name { 'Sydney Kingsford Smith Airport' }
      city { 'Sydney' }
      country { 'Australia' }
      latitude { -33.9399 }
      longitude { 151.1753 }
      is_international { true }
    end

    trait :dxb do
      code { 'DXB' }
      name { 'Dubai International Airport' }
      city { 'Dubai' }
      country { 'United Arab Emirates' }
      latitude { 25.2532 }
      longitude { 55.3657 }
      is_international { true }
    end

    trait :yyz do
      code { 'YYZ' }
      name { 'Toronto Pearson International Airport' }
      city { 'Toronto' }
      country { 'Canada' }
      latitude { 43.6777 }
      longitude { -79.6248 }
      is_international { true }
    end

    trait :mex do
      code { 'MEX' }
      name { 'Mexico City International Airport' }
      city { 'Mexico City' }
      country { 'Mexico' }
      latitude { 19.4363 }
      longitude { -99.0721 }
      is_international { true }
    end

    trait :ams do
      code { 'AMS' }
      name { 'Amsterdam Airport Schiphol' }
      city { 'Amsterdam' }
      country { 'Netherlands' }
      latitude { 52.3105 }
      longitude { 4.7683 }
      is_international { true }
    end

    trait :sin do
      code { 'SIN' }
      name { 'Singapore Changi Airport' }
      city { 'Singapore' }
      country { 'Singapore' }
      latitude { 1.3644 }
      longitude { 103.9915 }
      is_international { true }
    end

    trait :gru do
      code { 'GRU' }
      name { 'São Paulo/Guarulhos International Airport' }
      city { 'São Paulo' }
      country { 'Brazil' }
      latitude { -23.4356 }
      longitude { -46.4731 }
      is_international { true }
    end

    trait :international do
      is_international { true }
    end
  end
end

FactoryBot.define do
  factory :aircraft do
    model { 'Boeing 737-800' }
    economy_seats { 126 }
    comfort_plus_seats { 36 }
    business_seats { 16 }
    first_seats { 0 }
    total_seats { 178 }
    aisle_type { 'single' }

    trait :boeing_737 do
      model { 'Boeing 737-800' }
      economy_seats { 126 }
      comfort_plus_seats { 36 }
      business_seats { 16 }
      first_seats { 0 }
      total_seats { 178 }
      aisle_type { 'single' }
    end

    trait :boeing_757 do
      model { 'Boeing 757-200' }
      economy_seats { 168 }
      comfort_plus_seats { 44 }
      business_seats { 24 }
      first_seats { 0 }
      total_seats { 236 }
      aisle_type { 'single' }
    end

    trait :boeing_767 do
      model { 'Boeing 767-300ER' }
      economy_seats { 175 }
      comfort_plus_seats { 35 }
      business_seats { 26 }
      first_seats { 0 }
      total_seats { 236 }
      aisle_type { 'twin' }
    end

    trait :boeing_777 do
      model { 'Boeing 777-200LR' }
      economy_seats { 218 }
      comfort_plus_seats { 48 }
      business_seats { 52 }
      first_seats { 8 }
      total_seats { 326 }
      aisle_type { 'twin' }
    end

    trait :airbus_a320 do
      model { 'Airbus A320' }
      economy_seats { 120 }
      comfort_plus_seats { 36 }
      business_seats { 12 }
      first_seats { 0 }
      total_seats { 168 }
      aisle_type { 'single' }
    end

    trait :airbus_a330 do
      model { 'Airbus A330-300' }
      economy_seats { 211 }
      comfort_plus_seats { 40 }
      business_seats { 34 }
      first_seats { 0 }
      total_seats { 285 }
      aisle_type { 'twin' }
    end

    trait :airbus_a380 do
      model { 'Airbus A380-800' }
      economy_seats { 301 }
      comfort_plus_seats { 60 }
      business_seats { 76 }
      first_seats { 14 }
      total_seats { 451 }
      aisle_type { 'twin' }
    end

    trait :with_first_class do
      first_seats { 8 }
      total_seats { 186 }
    end
  end
end

FactoryBot.define do
  factory :seat do
    association :flight

    sequence(:seat_number) { |n| "#{(n / 6) + 1}#{%w[A B C D E F][n % 6]}" }
    row { 1 }
    column_letter { 'A' }
    deck { 'main' }
    seat_class { 'economy' }
    seat_type { 'window' }
    is_available { true }
    features { [] }

    # Seat class traits
    trait :economy do
      seat_class { 'economy' }
    end

    trait :comfort_plus do
      seat_class { 'comfort_plus' }
    end

    trait :business do
      seat_class { 'business' }
    end

    trait :first_class do
      seat_class { 'first' }
    end

    # Seat type traits
    trait :window do
      seat_type { 'window' }
      column_letter { 'A' }
    end

    trait :middle do
      seat_type { 'middle' }
      column_letter { 'B' }
    end

    trait :aisle do
      seat_type { 'aisle' }
      column_letter { 'C' }
    end

    # Deck traits (for A380)
    trait :main_deck do
      deck { 'main' }
    end

    trait :upper_deck do
      deck { 'upper' }
    end

    # Availability traits
    trait :available do
      is_available { true }
    end

    trait :taken do
      is_available { false }
    end

    # Feature traits
    trait :extra_legroom do
      features { ['extra_legroom'] }
    end

    trait :power_outlet do
      features { ['power_outlet'] }
    end

    trait :premium do
      features { %w[extra_legroom power_outlet priority_boarding] }
    end
  end
end

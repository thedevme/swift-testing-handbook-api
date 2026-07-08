FactoryBot.define do
  factory :purchase do
    sequence(:email) { |n| "buyer#{n}@example.com" }
    sequence(:order_number) { |n| "GUM-#{SecureRandom.hex(4).upcase}-#{n}" }
    product_id { 'swift-testing-handbook' }
    price_cents { 4900 }
    purchased_at { Time.current }

    trait :recent do
      purchased_at { 1.day.ago }
    end

    trait :old do
      purchased_at { 1.year.ago }
    end
  end
end

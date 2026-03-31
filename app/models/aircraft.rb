class Aircraft < ApplicationRecord
  self.table_name = 'aircraft'

  has_many :routes
  has_many :flights

  validates :model, presence: true
  validates :economy_seats, :comfort_plus_seats, :business_seats, :total_seats,
            presence: true, numericality: { greater_than_or_equal_to: 0 }
end

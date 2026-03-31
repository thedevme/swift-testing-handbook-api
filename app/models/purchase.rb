class Purchase < ApplicationRecord
  validates :email, :order_number, :purchased_at, presence: true
  validates :order_number, uniqueness: true
end

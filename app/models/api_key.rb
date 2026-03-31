class ApiKey < ApplicationRecord
  has_many :bookings

  validates :email, presence: true, uniqueness: true
  validates :token, presence: true, uniqueness: true

  before_validation :generate_token, on: :create

  private

  def generate_token
    self.token ||= "sk_#{SecureRandom.hex(16)}"
  end
end

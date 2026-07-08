class Airline < ApplicationRecord
  has_many :routes
  has_many :flights, through: :routes

  validates :code, presence: true, uniqueness: true, length: { is: 2 }
  validates :name, presence: true

  # Return the logo URL (prefer SVG, fallback to PNG)
  def logo_url(request_base_url = nil)
    base = request_base_url || ''
    if logo_svg.present?
      "#{base}/airline-logos/#{logo_svg}"
    elsif logo_png.present?
      "#{base}/airline-logos/#{logo_png}"
    else
      nil
    end
  end
end

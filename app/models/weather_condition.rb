class WeatherCondition < ApplicationRecord
  belongs_to :airport

  # Weather conditions
  CONDITION_TYPES = %w[sunny partly_cloudy cloudy rainy stormy snowy foggy].freeze
  WIND_DIRECTIONS = %w[N NE E SE S SW W NW].freeze

  # Weather icons for frontend
  CONDITION_ICONS = {
    'sunny' => '☀️',
    'partly_cloudy' => '⛅',
    'cloudy' => '☁️',
    'rainy' => '🌧️',
    'stormy' => '⛈️',
    'snowy' => '❄️',
    'foggy' => '🌫️'
  }.freeze

  validates :forecast_date, presence: true
  validates :temperature_f, presence: true
  validates :condition, presence: true, inclusion: { in: CONDITION_TYPES }
  validates :forecast_date, uniqueness: { scope: :airport_id }

  scope :for_date, ->(date) { where(forecast_date: date) }
  scope :upcoming, -> { where('forecast_date >= ?', Date.current).order(:forecast_date) }

  def icon
    CONDITION_ICONS[condition] || '🌤️'
  end

  def as_json(options = {})
    super(options).merge(
      'icon' => icon
    )
  end

  # Generate realistic weather for a city based on latitude and season
  def self.generate_for_airport(airport, date = Date.current)
    # Climate zones based on latitude
    climate = determine_climate(airport.latitude)
    season = determine_season(date, airport.latitude >= 0)

    # Base temperature by climate and season
    base_temp = base_temperature(climate, season)
    temp = base_temp + rand(-10..10)

    # Condition weights by climate and season
    condition = weighted_condition(climate, season)

    # Other weather attributes
    humidity = case climate
    when :tropical then rand(70..95)
    when :temperate then rand(40..70)
    when :cold then rand(30..60)
    when :arid then rand(10..30)
    end

    wind_speed = rand(5..25)
    wind_direction = WIND_DIRECTIONS.sample

    precip_chance = case condition
    when 'rainy', 'stormy' then rand(60..95)
    when 'snowy' then rand(50..90)
    when 'cloudy' then rand(20..40)
    when 'partly_cloudy' then rand(10..30)
    else rand(0..10)
    end

    visibility = case condition
    when 'foggy' then rand(1..3)
    when 'rainy', 'snowy', 'stormy' then rand(3..7)
    else 10
    end

    create!(
      airport: airport,
      forecast_date: date,
      temperature_f: temp,
      feels_like_f: temp + (humidity > 70 ? rand(5..10) : rand(-5..5)),
      condition: condition,
      humidity_percent: humidity,
      wind_speed_mph: wind_speed,
      wind_direction: wind_direction,
      precipitation_chance_percent: precip_chance,
      visibility_miles: visibility
    )
  end

  # Generate 7-day forecast for all airports
  def self.generate_forecasts(days = 7)
    Airport.find_each do |airport|
      days.times do |i|
        date = Date.current + i.days

        # Skip if already exists
        next if exists?(airport: airport, forecast_date: date)

        generate_for_airport(airport, date)
      end
    end
  end

  private

  def self.determine_climate(latitude)
    abs_lat = latitude.abs
    case abs_lat
    when 0..23 then :tropical
    when 23..40 then :temperate
    when 40..60 then :cold
    else :arctic
    end
  end

  def self.determine_season(date, northern_hemisphere)
    month = date.month

    if northern_hemisphere
      case month
      when 12, 1, 2 then :winter
      when 3, 4, 5 then :spring
      when 6, 7, 8 then :summer
      when 9, 10, 11 then :fall
      end
    else
      # Southern hemisphere - seasons reversed
      case month
      when 12, 1, 2 then :summer
      when 3, 4, 5 then :fall
      when 6, 7, 8 then :winter
      when 9, 10, 11 then :spring
      end
    end
  end

  def self.base_temperature(climate, season)
    temps = {
      tropical: { winter: 75, spring: 80, summer: 85, fall: 80 },
      temperate: { winter: 40, spring: 60, summer: 75, fall: 55 },
      cold: { winter: 20, spring: 45, summer: 65, fall: 45 },
      arid: { winter: 55, spring: 70, summer: 95, fall: 70 },
      arctic: { winter: 0, spring: 25, summer: 45, fall: 20 }
    }
    temps[climate][season] || 60
  end

  def self.weighted_condition(climate, season)
    weights = case climate
    when :tropical
      season == :summer ?
        { 'sunny' => 40, 'partly_cloudy' => 30, 'rainy' => 20, 'cloudy' => 10 } :
        { 'sunny' => 50, 'partly_cloudy' => 35, 'cloudy' => 10, 'rainy' => 5 }
    when :temperate
      case season
      when :summer then { 'sunny' => 60, 'partly_cloudy' => 25, 'cloudy' => 10, 'rainy' => 5 }
      when :winter then { 'cloudy' => 40, 'rainy' => 25, 'snowy' => 20, 'partly_cloudy' => 10, 'sunny' => 5 }
      when :spring, :fall then { 'partly_cloudy' => 40, 'sunny' => 30, 'cloudy' => 20, 'rainy' => 10 }
      end
    when :cold
      season == :winter ?
        { 'snowy' => 40, 'cloudy' => 35, 'partly_cloudy' => 15, 'sunny' => 10 } :
        { 'partly_cloudy' => 40, 'sunny' => 30, 'cloudy' => 20, 'rainy' => 10 }
    when :arid
      { 'sunny' => 70, 'partly_cloudy' => 20, 'cloudy' => 8, 'foggy' => 2 }
    else
      { 'sunny' => 50, 'partly_cloudy' => 30, 'cloudy' => 15, 'rainy' => 5 }
    end

    # Weighted random selection
    total = weights.values.sum
    roll = rand(total)
    cumulative = 0
    weights.each do |condition, weight|
      cumulative += weight
      return condition if roll < cumulative
    end
    'sunny' # fallback
  end
end

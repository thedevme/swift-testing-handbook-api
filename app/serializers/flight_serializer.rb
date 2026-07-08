class FlightSerializer
  def initialize(flight, include_weather: true)
    @flight = flight
    @include_weather = include_weather
  end

  def as_json
    {
      id: @flight.id,
      flight_number: @flight.flight_number,
      airline: airline_json,
      origin: airport_json(@flight.origin),
      destination: airport_json(@flight.destination),
      departure_at: @flight.scheduled_departure_at.iso8601,
      arrival_at: @flight.scheduled_arrival_at.iso8601,
      duration_minutes: @flight.duration_minutes,
      status: @flight.status,
      delay_minutes: @flight.delay_minutes,
      diverted_to: @flight.diverted_to,
      is_international: @flight.route.is_international,
      aircraft: aircraft_json,
      pricing: pricing_json,
      seats_available: seats_summary
    }
  end

  private

  def airport_json(airport)
    json = {
      code: airport.code,
      name: airport.name,
      city: airport.city
    }

    # Add weather if requested and available
    if @include_weather
      departure_date = @flight.scheduled_departure_at.to_date
      weather = airport.weather_for(departure_date)

      if weather
        json[:weather] = {
          temperature: weather.temperature_f,
          feels_like: weather.feels_like_f,
          condition: weather.condition,
          icon: weather.icon,
          humidity: weather.humidity_percent,
          precipitation_chance: weather.precipitation_chance_percent
        }
      end
    end

    json
  end

  def airline_json
    return nil unless @flight.route.airline

    airline = @flight.route.airline
    base_url = "http://localhost:3001" # TODO: Make this dynamic based on request

    {
      code: airline.code,
      name: airline.name,
      logo: {
        svg: airline.logo_svg ? "#{base_url}/airline-logos/#{airline.logo_svg}" : nil,
        png: airline.logo_png ? "#{base_url}/airline-logos/#{airline.logo_png}" : nil
      }
    }
  end

  def aircraft_json
    {
      model: @flight.aircraft.model,
      aisle_type: @flight.aircraft.aisle_type,
      is_double_deck: @flight.aircraft.model.include?('A380')
    }
  end

  def pricing_json
    pricing = {
      economy: @flight.economy_price_cents / 100,
      comfort_plus: @flight.comfort_plus_price_cents / 100
    }

    # Include business if available (international flights)
    if @flight.business_price_cents && @flight.business_price_cents > 0
      pricing[:business] = @flight.business_price_cents / 100
    end

    # Include first if available (domestic flights)
    if @flight.first_price_cents && @flight.first_price_cents > 0
      pricing[:first] = @flight.first_price_cents / 100
    end

    pricing
  end

  def seats_summary
    seats = @flight.seats
    summary = {
      economy: seats.economy.available.count,
      comfort_plus: seats.comfort_plus.available.count,
      total: seats.available.count
    }

    # Include business/first counts if aircraft has them
    business_count = seats.business.available.count
    first_count = seats.first_class.available.count

    summary[:business] = business_count if business_count > 0 || @flight.aircraft.business_seats > 0
    summary[:first] = first_count if first_count > 0 || @flight.aircraft.first_seats > 0

    summary
  end
end

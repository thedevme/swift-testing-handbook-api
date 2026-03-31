class FlightSerializer
  def initialize(flight)
    @flight = flight
  end

  def as_json
    {
      id: @flight.id,
      flight_number: @flight.flight_number,
      origin: airport_json(@flight.origin),
      destination: airport_json(@flight.destination),
      departure_at: @flight.scheduled_departure_at.iso8601,
      arrival_at: @flight.scheduled_arrival_at.iso8601,
      duration_minutes: @flight.duration_minutes,
      status: @flight.status,
      delay_minutes: @flight.delay_minutes,
      diverted_to: @flight.diverted_to,
      is_international: @flight.route.is_international,
      aircraft: { model: @flight.aircraft.model },
      pricing: {
        economy: @flight.economy_price_cents / 100,
        comfort_plus: @flight.comfort_plus_price_cents / 100,
        business: @flight.business_price_cents / 100
      },
      seats_available: seats_summary
    }
  end

  private

  def airport_json(airport)
    {
      code: airport.code,
      name: airport.name,
      city: airport.city
    }
  end

  def seats_summary
    seats = @flight.seats
    {
      economy: seats.economy.available.count,
      comfort_plus: seats.comfort_plus.available.count,
      business: seats.business.available.count,
      total: seats.available.count
    }
  end
end

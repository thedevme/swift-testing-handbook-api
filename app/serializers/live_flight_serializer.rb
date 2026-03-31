class LiveFlightSerializer
  def initialize(flight, detailed: false)
    @flight = flight
    @detailed = detailed
  end

  def as_json
    position = @flight.current_position

    data = {
      id: @flight.id,
      flight_number: @flight.flight_number,
      origin: @flight.origin.code,
      destination: @flight.destination.code,
      status: @flight.status,
      departed_at: @flight.scheduled_departure_at.iso8601,
      arrives_at: @flight.scheduled_arrival_at.iso8601,
      progress_pct: position&.dig(:progress_pct),
      position: position&.slice(:lat, :lng),
      altitude_ft: 35000,
      speed_mph: 530
    }

    if @detailed
      data.merge!(
        origin: { code: @flight.origin.code, city: @flight.origin.city },
        destination: { code: @flight.destination.code, city: @flight.destination.city },
        time_remaining_min: @flight.time_remaining_minutes,
        aircraft: @flight.aircraft.model,
        delay_minutes: @flight.delay_minutes
      )
    end

    data
  end
end

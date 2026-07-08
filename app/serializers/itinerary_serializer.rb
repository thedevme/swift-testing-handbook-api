class ItinerarySerializer
  def initialize(itinerary)
    @itinerary = itinerary
  end

  def as_json
    {
      id: @itinerary.id,
      reference: @itinerary.reference,
      status: @itinerary.status,
      passenger_name: @itinerary.passenger_name,
      trip_type: 'multi_city',
      route: @itinerary.route_summary,
      legs: legs_json,
      leg_count: @itinerary.leg_count,
      total_price: @itinerary.total_price_cents / 100,
      created_at: @itinerary.created_at.iso8601
    }
  end

  private

  def legs_json
    @itinerary.legs_in_order.map do |leg|
      {
        leg_number: leg.leg_number,
        status: leg.status,
        flight: flight_json(leg),
        seat: seat_json(leg)
      }
    end
  end

  def flight_json(leg)
    {
      id: leg.flight.id,
      flight_number: leg.flight.flight_number,
      origin: airport_json(leg.flight.origin),
      destination: airport_json(leg.flight.destination),
      departure_at: leg.flight.scheduled_departure_at.iso8601,
      arrival_at: leg.flight.scheduled_arrival_at.iso8601,
      duration_minutes: leg.flight.duration_minutes,
      status: leg.flight.status
    }
  end

  def seat_json(leg)
    {
      id: leg.seat.id,
      seat_number: leg.seat.seat_number,
      seat_class: leg.seat.seat_class,
      seat_type: leg.seat.seat_type,
      price: leg.seat.price_cents / 100
    }
  end

  def airport_json(airport)
    {
      code: airport.code,
      name: airport.name,
      city: airport.city
    }
  end
end

class BookingSerializer
  def initialize(booking)
    @booking = booking
  end

  def as_json
    {
      id: @booking.id,
      reference: @booking.reference,
      status: @booking.status,
      flight: flight_json,
      seat: seat_json,
      passenger_name: @booking.passenger_name,
      created_at: @booking.created_at.iso8601
    }
  end

  private

  def flight_json
    {
      flight_number: @booking.flight.flight_number,
      departure_at: @booking.flight.scheduled_departure_at.iso8601,
      status: @booking.flight.status,
      delay_minutes: @booking.flight.delay_minutes,
      origin: @booking.flight.origin.code,
      destination: @booking.flight.destination.code
    }
  end

  def seat_json
    {
      seat_number: @booking.seat.seat_number,
      seat_class: @booking.seat.seat_class,
      seat_type: @booking.seat.seat_type,
      price: @booking.seat.price_cents / 100
    }
  end
end

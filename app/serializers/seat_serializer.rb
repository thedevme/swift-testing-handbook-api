class SeatSerializer
  def initialize(seat)
    @seat = seat
  end

  def as_json
    {
      id: @seat.id,
      seat_number: @seat.seat_number,
      row: @seat.row,
      column: @seat.column_letter,
      deck: @seat.deck,
      seat_class: @seat.seat_class,
      seat_type: @seat.seat_type,
      features: @seat.features,
      is_available: @seat.is_available,
      price: @seat.price_cents ? @seat.price_cents / 100 : nil
    }
  end
end

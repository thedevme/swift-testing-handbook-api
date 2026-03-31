module Api
  module V1
    class BookingsController < ApplicationController
      # POST /api/v1/bookings
      def create
        flight = Flight.find(params[:flight_id])
        seat = flight.seats.find(params[:seat_id])

        # Check flight status
        if flight.cancelled?
          return render_error(code: 'FLIGHT_CANCELLED', message: 'This flight has been cancelled', status: :unprocessable_entity)
        end

        if flight.diverted?
          return render_error(code: 'FLIGHT_DIVERTED', message: 'This flight has been diverted — no new bookings', status: :unprocessable_entity)
        end

        # Check seat availability
        unless seat.is_available?
          return render_error(code: 'SEAT_TAKEN', message: "Seat #{seat.seat_number} is no longer available", status: :conflict)
        end

        # Check for duplicate booking
        existing = current_api_key.bookings.confirmed.find_by(flight: flight)
        if existing
          return render_error(
            code: 'DUPLICATE_BOOKING',
            message: 'You already have a booking on this flight',
            status: :unprocessable_entity,
            details: { existing_reference: existing.reference }
          )
        end

        booking = current_api_key.bookings.create!(
          flight: flight,
          seat: seat,
          passenger_name: params[:passenger_name]
        )

        render json: { data: BookingSerializer.new(booking).as_json }, status: :created

      rescue ActiveRecord::RecordNotFound
        render_error(code: 'NOT_FOUND', message: 'Flight or seat not found', status: :not_found)
      rescue ActiveRecord::RecordInvalid => e
        render_error(code: 'VALIDATION_ERROR', message: e.message, status: :unprocessable_entity)
      end

      # GET /api/v1/bookings
      def index
        bookings = current_api_key.bookings.includes(:flight, :seat, flight: { route: [:origin, :destination] })
        render json: { data: bookings.map { |b| BookingSerializer.new(b).as_json } }
      end

      # GET /api/v1/bookings/:id
      def show
        booking = Booking.find(params[:id])

        unless booking.api_key_id == current_api_key.id
          return render_error(code: 'FORBIDDEN', message: 'This booking belongs to another user', status: :forbidden)
        end

        render json: { data: BookingSerializer.new(booking).as_json }
      rescue ActiveRecord::RecordNotFound
        render_error(code: 'NOT_FOUND', message: 'Booking not found', status: :not_found)
      end

      # DELETE /api/v1/bookings/:id
      def destroy
        booking = Booking.find(params[:id])

        unless booking.api_key_id == current_api_key.id
          return render_error(code: 'FORBIDDEN', message: 'This booking belongs to another user', status: :forbidden)
        end

        if booking.cancelled?
          return render_error(code: 'ALREADY_CANCELLED', message: 'Booking already cancelled', status: :unprocessable_entity)
        end

        booking.cancelled!

        render json: {
          data: {
            id: booking.id,
            reference: booking.reference,
            status: 'cancelled',
            seat_released: true
          }
        }
      rescue ActiveRecord::RecordNotFound
        render_error(code: 'NOT_FOUND', message: 'Booking not found', status: :not_found)
      end
    end
  end
end

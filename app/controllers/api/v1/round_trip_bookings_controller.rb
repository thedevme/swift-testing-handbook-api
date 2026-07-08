module Api
  module V1
    class RoundTripBookingsController < ApplicationController
      # POST /api/v1/round_trip_bookings
      def create
        # Validate required parameters
        required_params = [:outbound_flight_id, :outbound_seat_id, :return_flight_id, :return_seat_id, :passenger_name]
        missing = required_params.select { |p| params[p].blank? }

        if missing.any?
          return render_error(
            code: 'MISSING_PARAMETERS',
            message: "Missing required parameters: #{missing.join(', ')}",
            status: :unprocessable_entity
          )
        end

        # Find flights and seats
        outbound_flight = Flight.find(params[:outbound_flight_id])
        outbound_seat = outbound_flight.seats.find(params[:outbound_seat_id])

        return_flight = Flight.find(params[:return_flight_id])
        return_seat = return_flight.seats.find(params[:return_seat_id])

        # Validate both flights are bookable
        validate_flight_bookable!(outbound_flight, 'Outbound')
        validate_flight_bookable!(return_flight, 'Return')

        # Validate both seats are available
        validate_seat_available!(outbound_seat, 'Outbound')
        validate_seat_available!(return_seat, 'Return')

        # Validate return is after outbound
        if return_flight.scheduled_departure_at <= outbound_flight.scheduled_arrival_at
          return render_error(
            code: 'INVALID_RETURN_DATE',
            message: "Return flight must depart after outbound arrival (#{outbound_flight.scheduled_arrival_at.iso8601})",
            status: :unprocessable_entity,
            details: {
              outbound_arrival: outbound_flight.scheduled_arrival_at.iso8601,
              return_departure: return_flight.scheduled_departure_at.iso8601
            }
          )
        end

        # Check for duplicate bookings
        existing_outbound = current_api_key.bookings.confirmed.find_by(flight: outbound_flight)
        if existing_outbound
          return render_error(
            code: 'DUPLICATE_BOOKING',
            message: 'You already have a booking on the outbound flight',
            status: :unprocessable_entity,
            details: { existing_reference: existing_outbound.reference }
          )
        end

        existing_return = current_api_key.bookings.confirmed.find_by(flight: return_flight)
        if existing_return
          return render_error(
            code: 'DUPLICATE_BOOKING',
            message: 'You already have a booking on the return flight',
            status: :unprocessable_entity,
            details: { existing_reference: existing_return.reference }
          )
        end

        # Create both bookings in transaction (atomic - all or nothing)
        outbound_booking = nil
        return_booking = nil

        ActiveRecord::Base.transaction do
          # Create return booking first (so we can reference it)
          return_booking = current_api_key.bookings.create!(
            flight: return_flight,
            seat: return_seat,
            passenger_name: params[:passenger_name],
            trip_type: 'round_trip',
            is_outbound: false
          )

          # Create outbound booking with link to return
          outbound_booking = current_api_key.bookings.create!(
            flight: outbound_flight,
            seat: outbound_seat,
            passenger_name: params[:passenger_name],
            trip_type: 'round_trip',
            is_outbound: true,
            return_booking: return_booking
          )
        end

        render json: {
          data: {
            trip_type: 'round_trip',
            combined_reference: "#{outbound_booking.reference}/#{return_booking.reference}",
            outbound: BookingSerializer.new(outbound_booking).as_json,
            return: BookingSerializer.new(return_booking).as_json,
            total_price: (outbound_seat.price_cents + return_seat.price_cents) / 100
          }
        }, status: :created

      rescue ActiveRecord::RecordNotFound => e
        render_error(
          code: 'NOT_FOUND',
          message: 'Flight or seat not found',
          status: :not_found
        )
      rescue ActiveRecord::RecordInvalid => e
        render_error(
          code: 'VALIDATION_ERROR',
          message: e.message,
          status: :unprocessable_entity
        )
      end

      private

      def validate_flight_bookable!(flight, leg_name)
        if flight.cancelled?
          raise ActiveRecord::RecordInvalid.new(flight), "#{leg_name} flight has been cancelled"
        end

        if flight.diverted?
          raise ActiveRecord::RecordInvalid.new(flight), "#{leg_name} flight has been diverted"
        end
      end

      def validate_seat_available!(seat, leg_name)
        unless seat.is_available?
          raise ActiveRecord::RecordInvalid.new(seat), "#{leg_name} seat #{seat.seat_number} is no longer available"
        end
      end
    end
  end
end

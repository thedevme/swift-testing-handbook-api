module Api
  module V1
    class ItinerariesController < ApplicationController
      # POST /api/v1/itineraries
      def create
        legs_params = params[:legs]

        # Validate legs parameter
        unless legs_params.is_a?(Array) && legs_params.length >= 2 && legs_params.length <= 6
          return render_error(
            code: 'INVALID_LEGS',
            message: 'Multi-city requires 2-6 legs',
            status: :unprocessable_entity
          )
        end

        # Validate each leg has required fields
        legs_params.each_with_index do |leg, index|
          unless leg[:flight_id].present? && leg[:seat_id].present?
            return render_error(
              code: 'MISSING_LEG_DATA',
              message: "Leg #{index + 1} is missing flight_id or seat_id",
              status: :unprocessable_entity
            )
          end
        end

        unless params[:passenger_name].present?
          return render_error(
            code: 'MISSING_PASSENGER_NAME',
            message: 'passenger_name is required',
            status: :unprocessable_entity
          )
        end

        # Create itinerary with legs in transaction
        itinerary = nil

        ActiveRecord::Base.transaction do
          # Build itinerary
          itinerary = current_api_key.itineraries.new(
            passenger_name: params[:passenger_name],
            leg_count: legs_params.length
          )

          # Create flight legs
          total_price = 0

          legs_params.each_with_index do |leg_params, index|
            flight = Flight.find(leg_params[:flight_id])
            seat = flight.seats.find(leg_params[:seat_id])

            # Validate flight and seat
            validate_flight_bookable!(flight, index + 1)
            validate_seat_available!(seat, index + 1)

            # Check for duplicate booking
            existing = current_api_key.bookings.confirmed.find_by(flight: flight)
            if existing
              raise ActiveRecord::RecordInvalid.new(flight),
                    "You already have a booking on leg #{index + 1} (reference: #{existing.reference})"
            end

            flight_leg = itinerary.flight_legs.build(
              flight: flight,
              seat: seat,
              leg_number: index + 1
            )

            total_price += seat.price_cents
          end

          itinerary.total_price_cents = total_price
          itinerary.save!

          # Validate connections
          unless itinerary.valid_connections?
            raise ActiveRecord::RecordInvalid.new(itinerary)
          end
        end

        render json: {
          data: ItinerarySerializer.new(itinerary).as_json
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

      # GET /api/v1/itineraries
      def index
        itineraries = current_api_key.itineraries
                                     .includes(flight_legs: {
                                       flight: { route: [:origin, :destination] },
                                       seat: []
                                     })
                                     .order(created_at: :desc)

        render json: {
          data: itineraries.map { |i| ItinerarySerializer.new(i).as_json }
        }
      end

      # GET /api/v1/itineraries/:id
      def show
        itinerary = Itinerary.includes(flight_legs: {
                                flight: { route: [:origin, :destination] },
                                seat: []
                              })
                              .find(params[:id])

        unless itinerary.api_key_id == current_api_key.id
          return render_error(
            code: 'FORBIDDEN',
            message: 'This itinerary belongs to another user',
            status: :forbidden
          )
        end

        render json: {
          data: ItinerarySerializer.new(itinerary).as_json
        }

      rescue ActiveRecord::RecordNotFound
        render_error(
          code: 'NOT_FOUND',
          message: 'Itinerary not found',
          status: :not_found
        )
      end

      # DELETE /api/v1/itineraries/:id
      def destroy
        itinerary = Itinerary.includes(:flight_legs).find(params[:id])

        unless itinerary.api_key_id == current_api_key.id
          return render_error(
            code: 'FORBIDDEN',
            message: 'This itinerary belongs to another user',
            status: :forbidden
          )
        end

        if itinerary.cancelled?
          return render_error(
            code: 'ALREADY_CANCELLED',
            message: 'Itinerary already cancelled',
            status: :unprocessable_entity
          )
        end

        itinerary.cancel_all!

        render json: {
          data: {
            id: itinerary.id,
            reference: itinerary.reference,
            status: 'cancelled',
            seats_released: itinerary.leg_count
          }
        }

      rescue ActiveRecord::RecordNotFound
        render_error(
          code: 'NOT_FOUND',
          message: 'Itinerary not found',
          status: :not_found
        )
      end

      private

      def validate_flight_bookable!(flight, leg_number)
        if flight.cancelled?
          raise ActiveRecord::RecordInvalid.new(flight),
                "Leg #{leg_number} flight has been cancelled"
        end

        if flight.diverted?
          raise ActiveRecord::RecordInvalid.new(flight),
                "Leg #{leg_number} flight has been diverted"
        end
      end

      def validate_seat_available!(seat, leg_number)
        unless seat.is_available?
          raise ActiveRecord::RecordInvalid.new(seat),
                "Leg #{leg_number} seat #{seat.seat_number} is no longer available"
        end
      end
    end
  end
end

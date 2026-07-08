module Api
  module V1
    class MultiCityController < ApplicationController
      # POST /api/v1/flights/multi_city/search
      def search
        legs_params = params[:legs]

        # Validate legs parameter
        unless legs_params.is_a?(Array)
          return render_error(
            code: 'INVALID_LEGS',
            message: 'legs parameter must be an array',
            status: :unprocessable_entity
          )
        end

        unless legs_params.length >= 2
          return render_error(
            code: 'INSUFFICIENT_LEGS',
            message: 'Multi-city requires at least 2 legs',
            status: :unprocessable_entity
          )
        end

        if legs_params.length > 6
          return render_error(
            code: 'TOO_MANY_LEGS',
            message: 'Maximum 6 legs allowed',
            status: :unprocessable_entity
          )
        end

        # Validate each leg has required fields
        legs_params.each_with_index do |leg, index|
          missing = []
          missing << 'origin' unless leg[:origin].present?
          missing << 'destination' unless leg[:destination].present?
          missing << 'date' unless leg[:date].present?

          if missing.any?
            return render_error(
              code: 'MISSING_LEG_DATA',
              message: "Leg #{index + 1} is missing: #{missing.join(', ')}",
              status: :unprocessable_entity
            )
          end
        end

        # Search flights for each leg
        results = legs_params.map.with_index do |leg, index|
          begin
            date = Date.parse(leg[:date])
          rescue ArgumentError
            return render_error(
              code: 'INVALID_DATE',
              message: "Leg #{index + 1} has invalid date format. Use YYYY-MM-DD",
              status: :unprocessable_entity
            )
          end

          flights = Flight.includes(:route, :aircraft, :seats, route: [:origin, :destination])
                          .joins(route: [:origin, :destination])
                          .where(airports: { code: leg[:origin] })
                          .where(destinations_routes: { code: leg[:destination] })
                          .where(scheduled_departure_at: date.beginning_of_day..date.end_of_day)
                          .bookable
                          .order(scheduled_departure_at: :asc)
                          .limit(20)

          {
            leg_number: index + 1,
            origin: leg[:origin],
            destination: leg[:destination],
            date: leg[:date],
            flights: flights.map { |f| FlightSerializer.new(f, include_weather: false).as_json }
          }
        end

        # Build route summary
        route_codes = results.map { |r| r[:origin] } + [results.last[:destination]]

        render json: {
          data: results,
          meta: {
            trip_type: 'multi_city',
            total_legs: legs_params.length,
            route: route_codes.join(' → ')
          }
        }
      end
    end
  end
end

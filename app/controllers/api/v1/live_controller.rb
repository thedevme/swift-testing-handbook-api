module Api
  module V1
    class LiveController < ApplicationController
      # GET /api/v1/live/flights
      def index
        flights = Flight.includes(:route, :aircraft, route: [:origin, :destination])
                        .select(&:in_air?)

        render json: {
          data: flights.map { |f| LiveFlightSerializer.new(f).as_json },
          meta: {
            flights_in_air: flights.count,
            generated_at: Time.current.iso8601
          }
        }
      end

      # GET /api/v1/live/flights/:id
      def show
        flight = Flight.includes(:route, :aircraft, route: [:origin, :destination]).find(params[:id])

        unless flight.in_air?
          return render_error(code: 'NOT_IN_AIR', message: 'Flight is not currently in the air', status: :unprocessable_entity)
        end

        render json: { data: LiveFlightSerializer.new(flight, detailed: true).as_json }
      rescue ActiveRecord::RecordNotFound
        render_error(code: 'NOT_FOUND', message: 'Flight not found', status: :not_found)
      end

      # GET /api/v1/live/stats
      def stats
        flights = Flight.all
        in_air = flights.select(&:in_air?)

        render json: {
          data: {
            flights_in_air: in_air.count,
            on_time_pct: calculate_on_time_percentage(flights),
            delayed_count: flights.delayed.count,
            cancelled_today: flights.cancelled.count,
            busiest_route: busiest_route,
            reset_at: next_reset_time.iso8601
          }
        }
      end

      private

      def calculate_on_time_percentage(flights)
        total = flights.where.not(status: 'scheduled').count
        return 0 if total.zero?
        ((flights.on_time.count.to_f / total) * 100).round
      end

      def busiest_route
        route = Route.joins(:flights)
                     .group('routes.id')
                     .order('COUNT(flights.id) DESC')
                     .includes(:origin, :destination)
                     .first
        return nil unless route
        "#{route.origin.code} → #{route.destination.code}"
      end

      def next_reset_time
        Time.current.utc.tomorrow.beginning_of_day
      end
    end
  end
end

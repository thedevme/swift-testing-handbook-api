module Api
  module V1
    class FlightsController < ApplicationController
      # GET /api/v1/flights
      def index
        flights = Flight.includes(:route, :aircraft, :seats, route: [:origin, :destination])

        flights = flights.joins(route: :origin).where(airports: { code: params[:origin] }) if params[:origin]
        flights = flights.joins(route: :destination).where(airports: { code: params[:destination] }) if params[:destination]
        flights = flights.where(status: params[:status]) if params[:status]

        if params[:date]
          date = Date.parse(params[:date])
          flights = flights.where(scheduled_departure_at: date.beginning_of_day..date.end_of_day)
        end

        flights = apply_sort(flights)

        total_count = flights.count
        flights = paginate(flights)

        render json: {
          data: flights.map { |f| FlightSerializer.new(f).as_json },
          meta: pagination_meta(total_count)
        }
      end

      # GET /api/v1/flights/:id
      def show
        flight = Flight.includes(:route, :aircraft, :seats, route: [:origin, :destination]).find(params[:id])
        render json: { data: FlightSerializer.new(flight).as_json }
      rescue ActiveRecord::RecordNotFound
        render_error(code: 'NOT_FOUND', message: 'Flight not found', status: :not_found)
      end

      private

      def apply_sort(flights)
        case params[:sort]
        when 'price_asc' then flights.order(economy_price_cents: :asc)
        when 'price_desc' then flights.order(economy_price_cents: :desc)
        when 'duration' then flights.order(duration_minutes: :asc)
        else flights.order(scheduled_departure_at: :asc)
        end
      end

      def paginate(flights)
        page = (params[:page] || 1).to_i
        per_page = [(params[:per_page] || 20).to_i, 100].min
        flights.offset((page - 1) * per_page).limit(per_page)
      end

      def pagination_meta(total)
        page = (params[:page] || 1).to_i
        per_page = [(params[:per_page] || 20).to_i, 100].min
        {
          total: total,
          page: page,
          per_page: per_page,
          total_pages: (total.to_f / per_page).ceil
        }
      end
    end
  end
end

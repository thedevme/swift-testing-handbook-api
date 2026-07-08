module Api
  module V1
    class FlightsController < ApplicationController
      # GET /api/v1/flights
      def index
        flights = Flight.includes(:route, :aircraft, :seats, route: [:origin, :destination])

        if params[:origin] && params[:destination]
          flights = flights.joins(route: [:origin, :destination])
                           .where(airports: { code: params[:origin] })
                           .where(destinations_routes: { code: params[:destination] })
        elsif params[:origin]
          flights = flights.joins(route: :origin).where(airports: { code: params[:origin] })
        elsif params[:destination]
          flights = flights.joins(route: :destination).where(airports: { code: params[:destination] })
        end
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

      # GET /api/v1/flights/round_trip
      def round_trip
        # Validate required parameters
        unless params[:origin] && params[:destination] && params[:outbound_date] && params[:return_date]
          return render_error(
            code: 'MISSING_PARAMETERS',
            message: 'origin, destination, outbound_date, and return_date are required',
            status: :unprocessable_entity
          )
        end

        # Validate dates
        begin
          outbound_date = Date.parse(params[:outbound_date])
          return_date = Date.parse(params[:return_date])
        rescue ArgumentError
          return render_error(
            code: 'INVALID_DATE',
            message: 'Invalid date format. Use YYYY-MM-DD',
            status: :unprocessable_entity
          )
        end

        if return_date <= outbound_date
          return render_error(
            code: 'INVALID_RETURN_DATE',
            message: 'Return date must be after outbound date',
            status: :unprocessable_entity
          )
        end

        # Search outbound flights
        outbound = Flight.includes(:route, :aircraft, :seats, route: [:origin, :destination])
                         .joins(route: [:origin, :destination])
                         .where(airports: { code: params[:origin] })
                         .where(destinations_routes: { code: params[:destination] })
                         .where(scheduled_departure_at: outbound_date.beginning_of_day..outbound_date.end_of_day)
                         .bookable
                         .order(scheduled_departure_at: :asc)
                         .limit(20)

        # Search return flights (reverse direction)
        return_flights = Flight.includes(:route, :aircraft, :seats, route: [:origin, :destination])
                               .joins(route: [:origin, :destination])
                               .where(airports: { code: params[:destination] })
                               .where(destinations_routes: { code: params[:origin] })
                               .where(scheduled_departure_at: return_date.beginning_of_day..return_date.end_of_day)
                               .bookable
                               .order(scheduled_departure_at: :asc)
                               .limit(20)

        render json: {
          data: {
            outbound: outbound.map { |f| FlightSerializer.new(f, include_weather: false).as_json },
            return: return_flights.map { |f| FlightSerializer.new(f, include_weather: false).as_json }
          },
          meta: {
            trip_type: 'round_trip',
            search: {
              origin: params[:origin],
              destination: params[:destination],
              outbound_date: params[:outbound_date],
              return_date: params[:return_date]
            },
            results: {
              outbound_count: outbound.length,
              return_count: return_flights.length
            }
          }
        }
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

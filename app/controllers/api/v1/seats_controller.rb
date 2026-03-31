module Api
  module V1
    class SeatsController < ApplicationController
      before_action :set_flight

      # GET /api/v1/flights/:flight_id/seats
      def index
        seats = @flight.seats

        seats = seats.where(seat_class: params[:class]) if params[:class]
        seats = seats.available if params[:available] == 'true'
        seats = seats.where(seat_type: params[:type]) if params[:type]

        seat_map = {
          business: seats.business.order(:seat_number).map { |s| SeatSerializer.new(s).as_json },
          comfort_plus: seats.comfort_plus.order(:seat_number).map { |s| SeatSerializer.new(s).as_json },
          economy: seats.economy.order(:seat_number).map { |s| SeatSerializer.new(s).as_json }
        }

        render json: {
          data: {
            flight_id: @flight.id,
            flight_number: @flight.flight_number,
            reset_note: "Seat availability randomizes every Sunday at midnight UTC",
            seat_map: seat_map,
            summary: {
              total: @flight.seats.count,
              available: @flight.seats.available.count,
              taken: @flight.seats.where(is_available: false).count
            }
          }
        }
      end

      # GET /api/v1/flights/:flight_id/seats/:id
      def show
        seat = @flight.seats.find(params[:id])
        render json: { data: SeatSerializer.new(seat).as_json }
      rescue ActiveRecord::RecordNotFound
        render_error(code: 'NOT_FOUND', message: 'Seat not found', status: :not_found)
      end

      private

      def set_flight
        @flight = Flight.find(params[:flight_id])
      rescue ActiveRecord::RecordNotFound
        render_error(code: 'NOT_FOUND', message: 'Flight not found', status: :not_found)
      end
    end
  end
end

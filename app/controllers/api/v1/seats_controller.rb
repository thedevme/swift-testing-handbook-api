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
        seats = seats.on_deck(params[:deck]) if params[:deck]

        is_double_deck = @flight.aircraft.model.include?('A380')

        if is_double_deck
          seat_map = build_double_deck_map(seats)
        else
          seat_map = build_single_deck_map(seats)
        end

        render json: {
          data: {
            flight_id: @flight.id,
            flight_number: @flight.flight_number,
            aircraft: @flight.aircraft.model,
            aisle_type: @flight.aircraft.aisle_type,
            is_double_deck: is_double_deck,
            reset_note: "Seat availability randomizes every Sunday at midnight UTC",
            seat_map: seat_map,
            summary: build_summary
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
        @flight = Flight.includes(:aircraft).find(params[:flight_id])
      rescue ActiveRecord::RecordNotFound
        render_error(code: 'NOT_FOUND', message: 'Flight not found', status: :not_found)
      end

      def build_single_deck_map(seats)
        {
          first: serialize_seats(seats.first_class.order(:row, :column_letter)),
          business: serialize_seats(seats.business.order(:row, :column_letter)),
          comfort_plus: serialize_seats(seats.comfort_plus.order(:row, :column_letter)),
          economy: serialize_seats(seats.economy.order(:row, :column_letter))
        }
      end

      def build_double_deck_map(seats)
        {
          upper_deck: {
            first: serialize_seats(seats.on_deck('upper').first_class.order(:row, :column_letter)),
            business: serialize_seats(seats.on_deck('upper').business.order(:row, :column_letter))
          },
          main_deck: {
            comfort_plus: serialize_seats(seats.on_deck('main').comfort_plus.order(:row, :column_letter)),
            economy: serialize_seats(seats.on_deck('main').economy.order(:row, :column_letter))
          }
        }
      end

      def serialize_seats(seats)
        seats.map { |s| SeatSerializer.new(s).as_json }
      end

      def build_summary
        seats = @flight.seats
        {
          total: seats.count,
          available: seats.available.count,
          taken: seats.where(is_available: false).count,
          by_class: {
            first: { total: seats.first_class.count, available: seats.first_class.available.count },
            business: { total: seats.business.count, available: seats.business.available.count },
            comfort_plus: { total: seats.comfort_plus.count, available: seats.comfort_plus.available.count },
            economy: { total: seats.economy.count, available: seats.economy.available.count }
          }
        }
      end
    end
  end
end

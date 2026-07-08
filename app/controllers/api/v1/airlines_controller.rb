module Api
  module V1
    class AirlinesController < ApplicationController
      skip_before_action :authenticate_reader, only: [:index, :show]

      # GET /api/v1/airlines
      def index
        airlines = Airline.all.order(:name)

        render json: {
          data: airlines.map { |airline| serialize_airline(airline) }
        }
      end

      # GET /api/v1/airlines/:code
      def show
        airline = Airline.find_by!(code: params[:id].upcase)

        render json: {
          data: serialize_airline(airline)
        }
      rescue ActiveRecord::RecordNotFound
        render_error(code: 'NOT_FOUND', message: 'Airline not found', status: :not_found)
      end

      private

      def serialize_airline(airline)
        {
          code: airline.code,
          name: airline.name,
          country: airline.country,
          airline_type: airline.airline_type,
          logo: {
            svg: airline.logo_svg ? "#{request.base_url}/airline-logos/#{airline.logo_svg}" : nil,
            png: airline.logo_png ? "#{request.base_url}/airline-logos/#{airline.logo_png}" : nil
          },
          created_at: airline.created_at.iso8601
        }
      end
    end
  end
end

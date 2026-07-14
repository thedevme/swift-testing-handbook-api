module Api
  module V1
    class CitiesController < ApplicationController
      # GET /api/v1/cities
      def index
        airports = Airport.all

        # Filter by country if provided
        airports = airports.where(country: params[:country]) if params[:country].present?

        # Filter by international status if provided
        if params[:international].present?
          is_international = ActiveModel::Type::Boolean.new.cast(params[:international])
          airports = airports.where(is_international: is_international)
        end

        # Filter by hub tier if provided
        airports = airports.where(hub_tier: params[:hub_tier]) if params[:hub_tier].present?

        # Order by city name
        airports = airports.order(:city, :code)

        # Group airports by city
        cities_data = airports.group_by(&:city).map do |city_name, city_airports|
          {
            city: city_name,
            country: city_airports.first.country,
            state: city_airports.first.state,
            is_international: city_airports.any?(&:is_international),
            airports: city_airports.map do |airport|
              {
                code: airport.code,
                name: airport.name,
                latitude: airport.latitude,
                longitude: airport.longitude,
                hub_tier: airport.hub_tier
              }
            end
          }
        end

        render json: {
          data: cities_data,
          meta: {
            total_cities: cities_data.count,
            total_airports: airports.count,
            filters: {
              country: params[:country],
              international: params[:international],
              hub_tier: params[:hub_tier]
            }.compact
          }
        }
      end
    end
  end
end

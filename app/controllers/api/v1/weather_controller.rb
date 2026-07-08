module Api
  module V1
    class WeatherController < ApplicationController
      skip_before_action :authenticate_reader, only: [:index, :show]

      # GET /api/v1/weather?airport=TPA&date=2026-06-15
      def index
        airport_code = params[:airport]
        date = params[:date] ? Date.parse(params[:date]) : Date.current

        unless airport_code
          return render_error(
            code: 'MISSING_AIRPORT',
            message: 'Airport code is required',
            status: :unprocessable_entity
          )
        end

        airport = Airport.find_by(code: airport_code.upcase)
        unless airport
          return render_error(
            code: 'AIRPORT_NOT_FOUND',
            message: "Airport #{airport_code} not found",
            status: :not_found
          )
        end

        weather = airport.weather_for(date)
        unless weather
          # Generate if missing
          weather = WeatherCondition.generate_for_airport(airport, date)
        end

        render json: {
          data: {
            airport: {
              code: airport.code,
              name: airport.name,
              city: airport.city
            },
            date: date.iso8601,
            weather: {
              temperature: weather.temperature_f,
              feels_like: weather.feels_like_f,
              condition: weather.condition,
              icon: weather.icon,
              humidity: weather.humidity_percent,
              wind_speed: weather.wind_speed_mph,
              wind_direction: weather.wind_direction,
              precipitation_chance: weather.precipitation_chance_percent,
              visibility: weather.visibility_miles
            }
          }
        }

      rescue Date::Error
        render_error(
          code: 'INVALID_DATE',
          message: 'Invalid date format. Use YYYY-MM-DD',
          status: :unprocessable_entity
        )
      end

      # GET /api/v1/weather/forecast?airport=TPA&days=7
      def forecast
        airport_code = params[:airport]
        days = (params[:days] || 7).to_i
        days = [[days, 1].max, 14].min # Between 1 and 14 days

        unless airport_code
          return render_error(
            code: 'MISSING_AIRPORT',
            message: 'Airport code is required',
            status: :unprocessable_entity
          )
        end

        airport = Airport.find_by(code: airport_code.upcase)
        unless airport
          return render_error(
            code: 'AIRPORT_NOT_FOUND',
            message: "Airport #{airport_code} not found",
            status: :not_found
          )
        end

        forecast_data = []
        days.times do |i|
          date = Date.current + i.days
          weather = airport.weather_for(date) || WeatherCondition.generate_for_airport(airport, date)

          forecast_data << {
            date: date.iso8601,
            temperature: weather.temperature_f,
            feels_like: weather.feels_like_f,
            condition: weather.condition,
            icon: weather.icon,
            humidity: weather.humidity_percent,
            precipitation_chance: weather.precipitation_chance_percent
          }
        end

        render json: {
          data: {
            airport: {
              code: airport.code,
              name: airport.name,
              city: airport.city
            },
            forecast: forecast_data
          }
        }
      end
    end
  end
end

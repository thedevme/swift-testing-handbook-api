require 'rails_helper'

RSpec.configure do |config|
  config.openapi_root = Rails.root.join('swagger').to_s

  config.openapi_specs = {
    'v1/swagger.yaml' => {
      openapi: '3.0.1',
      info: {
        title: 'SkyBook Flight API',
        version: 'v1',
        description: <<~DESC
          The SkyBook API provides access to flight data, seat maps, and booking functionality
          for the Swift Testing Handbook companion app.

          ## Authentication

          All endpoints require a valid API key passed in the Authorization header:

          ```
          Authorization: Bearer sk_your_api_key_here
          ```

          API keys are issued upon purchase of the Swift Testing Handbook.

          ## Rate Limiting

          The API is rate-limited to 100 requests per minute per API key.

          ## Seat Availability

          Seat availability is randomized every Sunday at midnight UTC for testing purposes.
        DESC
      },
      paths: {},
      servers: [
        {
          url: 'http://localhost:3000',
          description: 'Development server'
        },
        {
          url: 'https://api.swifttestinghandbook.com',
          description: 'Production server'
        }
      ],
      components: {
        securitySchemes: {
          bearer_auth: {
            type: :http,
            scheme: :bearer,
            description: 'API key with sk_ prefix'
          }
        },
        schemas: {
          Airport: {
            type: :object,
            properties: {
              code: { type: :string, example: 'JFK' },
              name: { type: :string, example: 'John F. Kennedy International Airport' },
              city: { type: :string, example: 'New York' }
            }
          },
          Aircraft: {
            type: :object,
            properties: {
              model: { type: :string, example: 'Boeing 737-800' },
              aisle_type: { type: :string, enum: %w[single twin] },
              is_double_deck: { type: :boolean }
            }
          },
          Pricing: {
            type: :object,
            properties: {
              economy: { type: :integer, example: 150 },
              comfort_plus: { type: :integer, example: 250 },
              business: { type: :integer, example: 450, nullable: true },
              first: { type: :integer, example: 750, nullable: true }
            }
          },
          SeatsAvailable: {
            type: :object,
            properties: {
              economy: { type: :integer },
              comfort_plus: { type: :integer },
              business: { type: :integer },
              first: { type: :integer },
              total: { type: :integer }
            }
          },
          Flight: {
            type: :object,
            properties: {
              id: { type: :string, format: :uuid },
              flight_number: { type: :string, example: 'SK1234' },
              origin: { '$ref': '#/components/schemas/Airport' },
              destination: { '$ref': '#/components/schemas/Airport' },
              departure_at: { type: :string, format: 'date-time' },
              arrival_at: { type: :string, format: 'date-time' },
              duration_minutes: { type: :integer },
              status: { type: :string, enum: %w[scheduled on_time delayed boarding departed arrived cancelled diverted] },
              delay_minutes: { type: :integer, nullable: true },
              diverted_to: { type: :string, nullable: true },
              is_international: { type: :boolean },
              aircraft: { '$ref': '#/components/schemas/Aircraft' },
              pricing: { '$ref': '#/components/schemas/Pricing' },
              seats_available: { '$ref': '#/components/schemas/SeatsAvailable' }
            }
          },
          Seat: {
            type: :object,
            properties: {
              id: { type: :string, format: :uuid },
              seat_number: { type: :string, example: '15A' },
              row: { type: :integer },
              column: { type: :string, example: 'A' },
              deck: { type: :string, enum: %w[main upper] },
              seat_class: { type: :string, enum: %w[economy comfort_plus business first] },
              seat_type: { type: :string, enum: %w[window middle aisle] },
              features: { type: :array, items: { type: :string } },
              is_available: { type: :boolean },
              price: { type: :integer, description: 'Price in dollars' }
            }
          },
          Booking: {
            type: :object,
            properties: {
              id: { type: :string, format: :uuid },
              reference: { type: :string, example: 'SK1A2B' },
              status: { type: :string, enum: %w[confirmed cancelled] },
              flight: {
                type: :object,
                properties: {
                  flight_number: { type: :string },
                  departure_at: { type: :string, format: 'date-time' },
                  status: { type: :string },
                  delay_minutes: { type: :integer, nullable: true },
                  origin: { type: :string },
                  destination: { type: :string }
                }
              },
              seat: {
                type: :object,
                properties: {
                  seat_number: { type: :string },
                  seat_class: { type: :string },
                  seat_type: { type: :string },
                  price: { type: :integer }
                }
              },
              passenger_name: { type: :string },
              created_at: { type: :string, format: 'date-time' }
            }
          },
          LiveFlight: {
            type: :object,
            properties: {
              id: { type: :string, format: :uuid },
              flight_number: { type: :string },
              origin: { type: :string },
              destination: { type: :string },
              status: { type: :string },
              departed_at: { type: :string, format: 'date-time' },
              arrives_at: { type: :string, format: 'date-time' },
              progress_pct: { type: :integer },
              position: {
                type: :object,
                properties: {
                  lat: { type: :number },
                  lng: { type: :number }
                }
              },
              altitude_ft: { type: :integer },
              speed_mph: { type: :integer }
            }
          },
          Error: {
            type: :object,
            properties: {
              error: { type: :string },
              message: { type: :string },
              code: { type: :string }
            },
            required: %w[error message code]
          },
          PaginationMeta: {
            type: :object,
            properties: {
              total: { type: :integer },
              page: { type: :integer },
              per_page: { type: :integer },
              total_pages: { type: :integer }
            }
          }
        }
      },
      security: [{ bearer_auth: [] }]
    }
  }

  config.openapi_format = :yaml
end

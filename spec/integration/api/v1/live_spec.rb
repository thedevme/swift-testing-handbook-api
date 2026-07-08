require 'swagger_helper'

RSpec.describe 'Live Flights API', type: :request do
  let(:api_key) { create(:api_key) }
  let(:Authorization) { "Bearer #{api_key.token}" }

  path '/api/v1/live/flights' do
    get 'List flights currently in air' do
      tags 'Live Tracking'
      description <<~DESC
        Returns all flights that are currently in the air (between scheduled
        departure and arrival times, not cancelled or diverted).

        Each flight includes its current position, calculated by linear
        interpolation between origin and destination coordinates.
      DESC
      produces 'application/json'
      security [bearer_auth: []]

      response '200', 'live flights returned' do
        schema type: :object,
               properties: {
                 data: {
                   type: :array,
                   items: { '$ref': '#/components/schemas/LiveFlight' }
                 },
                 meta: {
                   type: :object,
                   properties: {
                     flights_in_air: { type: :integer },
                     generated_at: { type: :string, format: 'date-time' }
                   }
                 }
               }

        run_test!
      end

      response '401', 'unauthorized' do
        schema '$ref': '#/components/schemas/Error'

        let(:Authorization) { 'Bearer invalid_token' }

        run_test!
      end
    end
  end

  path '/api/v1/live/flights/{id}' do
    get 'Get live flight details' do
      tags 'Live Tracking'
      description <<~DESC
        Returns detailed tracking information for a specific flight that
        is currently in the air.

        Includes:
        - Current position (lat/lng)
        - Progress percentage
        - Time remaining
        - Altitude and speed
      DESC
      produces 'application/json'
      security [bearer_auth: []]

      parameter name: :id, in: :path, type: :string, format: :uuid, required: true,
                description: 'Flight ID'

      response '200', 'live flight data returned' do
        schema type: :object,
               properties: {
                 data: {
                   type: :object,
                   properties: {
                     id: { type: :string, format: :uuid },
                     flight_number: { type: :string },
                     origin: {
                       type: :object,
                       properties: {
                         code: { type: :string },
                         city: { type: :string }
                       }
                     },
                     destination: {
                       type: :object,
                       properties: {
                         code: { type: :string },
                         city: { type: :string }
                       }
                     },
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
                     time_remaining_min: { type: :integer },
                     aircraft: { type: :string },
                     altitude_ft: { type: :integer },
                     speed_mph: { type: :integer },
                     delay_minutes: { type: :integer, nullable: true }
                   }
                 }
               }

        let(:tpa) { create(:airport, :tpa) }
        let(:jfk) { create(:airport, :jfk) }
        let(:route) { create(:route, origin: tpa, destination: jfk) }
        let(:flight) { create(:flight, :in_air, route: route) }
        let(:id) { flight.id }

        run_test!
      end

      response '422', 'flight not in air' do
        schema '$ref': '#/components/schemas/Error'

        let(:flight) { create(:flight, :scheduled) }
        let(:id) { flight.id }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['code']).to eq('NOT_IN_AIR')
        end
      end

      response '404', 'flight not found' do
        schema '$ref': '#/components/schemas/Error'

        let(:id) { 'non-existent-id' }

        run_test!
      end

      response '401', 'unauthorized' do
        schema '$ref': '#/components/schemas/Error'

        let(:id) { create(:flight).id }
        let(:Authorization) { 'Bearer invalid_token' }

        run_test!
      end
    end
  end

  path '/api/v1/live/stats' do
    get 'Get airline statistics' do
      tags 'Live Tracking'
      description <<~DESC
        Returns aggregated statistics about current flight operations.

        Statistics include:
        - Number of flights currently in air
        - On-time performance percentage
        - Delayed and cancelled flight counts
        - Busiest route

        Statistics reset daily at midnight UTC.
      DESC
      produces 'application/json'
      security [bearer_auth: []]

      response '200', 'statistics returned' do
        schema type: :object,
               properties: {
                 data: {
                   type: :object,
                   properties: {
                     flights_in_air: { type: :integer },
                     on_time_pct: { type: :integer, description: 'Percentage of flights on time' },
                     delayed_count: { type: :integer },
                     cancelled_today: { type: :integer },
                     busiest_route: { type: :string, nullable: true, example: 'TPA → JFK' },
                     reset_at: { type: :string, format: 'date-time', description: 'When stats reset (midnight UTC)' }
                   }
                 }
               }

        run_test!
      end

      response '401', 'unauthorized' do
        schema '$ref': '#/components/schemas/Error'

        let(:Authorization) { 'Bearer invalid_token' }

        run_test!
      end
    end
  end
end

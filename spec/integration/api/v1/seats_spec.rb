require 'swagger_helper'

RSpec.describe 'Seats API', type: :request do
  let(:api_key) { create(:api_key) }
  let(:Authorization) { "Bearer #{api_key.token}" }

  path '/api/v1/flights/{flight_id}/seats' do
    get 'List seats for a flight' do
      tags 'Seats'
      description <<~DESC
        Returns the seat map for a specific flight, organized by seat class.
        For double-deck aircraft (A380), seats are also grouped by deck (upper/main).
      DESC
      produces 'application/json'
      security [bearer_auth: []]

      parameter name: :flight_id, in: :path, type: :string, format: :uuid, required: true,
                description: 'Flight ID'
      parameter name: :class, in: :query, type: :string, required: false,
                description: 'Filter by seat class',
                enum: %w[economy comfort_plus business first]
      parameter name: :available, in: :query, type: :string, required: false,
                description: 'Filter by availability (true/false)'
      parameter name: :type, in: :query, type: :string, required: false,
                description: 'Filter by seat type',
                enum: %w[window middle aisle]
      parameter name: :deck, in: :query, type: :string, required: false,
                description: 'Filter by deck (for A380)',
                enum: %w[main upper]

      response '200', 'seat map returned' do
        schema type: :object,
               properties: {
                 data: {
                   type: :object,
                   properties: {
                     flight_id: { type: :string, format: :uuid },
                     flight_number: { type: :string },
                     aircraft: { type: :string },
                     aisle_type: { type: :string },
                     is_double_deck: { type: :boolean },
                     reset_note: { type: :string },
                     seat_map: { type: :object },
                     summary: {
                       type: :object,
                       properties: {
                         total: { type: :integer },
                         available: { type: :integer },
                         taken: { type: :integer },
                         by_class: { type: :object }
                       }
                     }
                   }
                 }
               }

        let(:flight) { create(:flight) }
        let(:flight_id) { flight.id }

        before do
          create(:seat, flight: flight, seat_class: 'economy')
        end

        run_test!
      end

      response '404', 'flight not found' do
        schema '$ref': '#/components/schemas/Error'

        let(:flight_id) { 'non-existent-id' }

        run_test!
      end

      response '401', 'unauthorized' do
        schema '$ref': '#/components/schemas/Error'

        let(:flight) { create(:flight) }
        let(:flight_id) { flight.id }
        let(:Authorization) { 'Bearer invalid_token' }

        run_test!
      end
    end
  end

  path '/api/v1/flights/{flight_id}/seats/{id}' do
    get 'Get a specific seat' do
      tags 'Seats'
      description 'Returns detailed information about a specific seat.'
      produces 'application/json'
      security [bearer_auth: []]

      parameter name: :flight_id, in: :path, type: :string, format: :uuid, required: true,
                description: 'Flight ID'
      parameter name: :id, in: :path, type: :string, format: :uuid, required: true,
                description: 'Seat ID'

      response '200', 'seat found' do
        schema type: :object,
               properties: {
                 data: { '$ref': '#/components/schemas/Seat' }
               }

        let(:flight) { create(:flight) }
        let(:seat) { create(:seat, flight: flight) }
        let(:flight_id) { flight.id }
        let(:id) { seat.id }

        run_test!
      end

      response '404', 'seat not found' do
        schema '$ref': '#/components/schemas/Error'

        let(:flight) { create(:flight) }
        let(:flight_id) { flight.id }
        let(:id) { 'non-existent-id' }

        run_test!
      end

      response '401', 'unauthorized' do
        schema '$ref': '#/components/schemas/Error'

        let(:flight) { create(:flight) }
        let(:seat) { create(:seat, flight: flight) }
        let(:flight_id) { flight.id }
        let(:id) { seat.id }
        let(:Authorization) { 'Bearer invalid_token' }

        run_test!
      end
    end
  end
end

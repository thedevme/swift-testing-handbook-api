require 'swagger_helper'

RSpec.describe 'Flights API', type: :request do
  let(:api_key) { create(:api_key) }
  let(:Authorization) { "Bearer #{api_key.token}" }

  path '/api/v1/flights' do
    get 'List all flights' do
      tags 'Flights'
      description 'Returns a paginated list of flights with optional filtering and sorting.'
      produces 'application/json'
      security [bearer_auth: []]

      parameter name: :origin, in: :query, required: false,
                description: 'Filter by origin airport code',
                schema: { type: :string, enum: %w[TPA JFK LAX ORD BOS MIA SEA DEN ATL DFW LHR CDG NRT SYD DXB YYZ MEX AMS SIN GRU] }
      parameter name: :destination, in: :query, required: false,
                description: 'Filter by destination airport code',
                schema: { type: :string, enum: %w[TPA JFK LAX ORD BOS MIA SEA DEN ATL DFW LHR CDG NRT SYD DXB YYZ MEX AMS SIN GRU] }
      parameter name: :status, in: :query, required: false,
                description: 'Filter by flight status',
                schema: { type: :string, enum: %w[scheduled on_time delayed boarding departed arrived cancelled diverted] }
      parameter name: :date, in: :query, required: false,
                description: 'Filter by departure date (YYYY-MM-DD)',
                schema: { type: :string, format: :date }
      parameter name: :sort, in: :query, required: false,
                description: 'Sort order',
                schema: { type: :string, enum: %w[price_asc price_desc duration departure_time] }
      parameter name: :page, in: :query, required: false,
                description: 'Page number (default: 1)',
                schema: { type: :integer }
      parameter name: :per_page, in: :query, required: false,
                description: 'Results per page (default: 20, max: 100)',
                schema: { type: :integer }

      response '200', 'flights found' do
        schema type: :object,
               properties: {
                 data: {
                   type: :array,
                   items: { '$ref': '#/components/schemas/Flight' }
                 },
                 meta: { '$ref': '#/components/schemas/PaginationMeta' }
               }

        let!(:flight) { create(:flight) }

        run_test!
      end

      response '401', 'unauthorized' do
        schema '$ref': '#/components/schemas/Error'

        let(:Authorization) { 'Bearer invalid_token' }

        run_test!
      end
    end
  end

  path '/api/v1/flights/{id}' do
    get 'Get a specific flight' do
      tags 'Flights'
      description 'Returns detailed information about a specific flight.'
      produces 'application/json'
      security [bearer_auth: []]

      parameter name: :id, in: :path, type: :string, format: :uuid, required: true,
                description: 'Flight ID'

      response '200', 'flight found' do
        schema type: :object,
               properties: {
                 data: { '$ref': '#/components/schemas/Flight' }
               }

        let(:id) { create(:flight).id }

        run_test!
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
end

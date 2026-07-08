require 'swagger_helper'

RSpec.describe 'Bookings API', type: :request do
  let(:api_key) { create(:api_key) }
  let(:Authorization) { "Bearer #{api_key.token}" }

  path '/api/v1/bookings' do
    get 'List your bookings' do
      tags 'Bookings'
      description 'Returns all bookings associated with your API key.'
      produces 'application/json'
      security [bearer_auth: []]

      response '200', 'bookings returned' do
        schema type: :object,
               properties: {
                 data: {
                   type: :array,
                   items: { '$ref': '#/components/schemas/Booking' }
                 }
               }

        let!(:booking) { create(:booking, api_key: api_key) }

        run_test!
      end

      response '401', 'unauthorized' do
        schema '$ref': '#/components/schemas/Error'

        let(:Authorization) { 'Bearer invalid_token' }

        run_test!
      end
    end

    post 'Create a booking' do
      tags 'Bookings'
      description <<~DESC
        Creates a new booking for a flight seat.

        ## Validation Rules
        - The flight must not be cancelled or diverted
        - The seat must be available
        - You cannot have multiple confirmed bookings on the same flight
      DESC
      consumes 'application/json'
      produces 'application/json'
      security [bearer_auth: []]

      parameter name: :booking, in: :body, schema: {
        type: :object,
        properties: {
          flight_id: { type: :string, format: :uuid, description: 'ID of the flight to book' },
          seat_id: { type: :string, format: :uuid, description: 'ID of the seat to reserve' },
          passenger_name: { type: :string, description: 'Full name of the passenger', maxLength: 100 }
        },
        required: %w[flight_id seat_id passenger_name]
      }

      response '201', 'booking created' do
        schema type: :object,
               properties: {
                 data: { '$ref': '#/components/schemas/Booking' }
               }

        let(:flight) { create(:flight, :scheduled) }
        let(:seat) { create(:seat, flight: flight, is_available: true) }
        let(:booking) do
          {
            flight_id: flight.id,
            seat_id: seat.id,
            passenger_name: 'John Doe'
          }
        end

        run_test!
      end

      response '409', 'seat taken' do
        schema '$ref': '#/components/schemas/Error'

        let(:flight) { create(:flight) }
        let(:seat) { create(:seat, flight: flight, is_available: false) }
        let(:booking) do
          {
            flight_id: flight.id,
            seat_id: seat.id,
            passenger_name: 'John Doe'
          }
        end

        run_test!
      end

      response '422', 'validation error' do
        schema type: :object,
               properties: {
                 error: { type: :string },
                 message: { type: :string },
                 code: { type: :string },
                 details: { type: :object }
               }

        let(:flight) { create(:flight, :cancelled) }
        let(:seat) { create(:seat, flight: flight) }
        let(:booking) do
          {
            flight_id: flight.id,
            seat_id: seat.id,
            passenger_name: 'John Doe'
          }
        end

        run_test!
      end

      response '401', 'unauthorized' do
        schema '$ref': '#/components/schemas/Error'

        let(:Authorization) { 'Bearer invalid_token' }
        let(:booking) { {} }

        run_test!
      end
    end
  end

  path '/api/v1/bookings/{id}' do
    get 'Get a specific booking' do
      tags 'Bookings'
      description 'Returns details of a specific booking. You can only view your own bookings.'
      produces 'application/json'
      security [bearer_auth: []]

      parameter name: :id, in: :path, type: :string, format: :uuid, required: true,
                description: 'Booking ID'

      response '200', 'booking found' do
        schema type: :object,
               properties: {
                 data: { '$ref': '#/components/schemas/Booking' }
               }

        let(:booking_record) { create(:booking, api_key: api_key) }
        let(:id) { booking_record.id }

        run_test!
      end

      response '403', 'forbidden' do
        schema '$ref': '#/components/schemas/Error'

        let(:other_booking) { create(:booking) }
        let(:id) { other_booking.id }

        run_test!
      end

      response '404', 'booking not found' do
        schema '$ref': '#/components/schemas/Error'

        let(:id) { 'non-existent-id' }

        run_test!
      end

      response '401', 'unauthorized' do
        schema '$ref': '#/components/schemas/Error'

        let(:id) { create(:booking).id }
        let(:Authorization) { 'Bearer invalid_token' }

        run_test!
      end
    end

    delete 'Cancel a booking' do
      tags 'Bookings'
      description <<~DESC
        Cancels a booking and releases the seat.

        You can only cancel your own bookings.
        Already cancelled bookings cannot be cancelled again.
      DESC
      produces 'application/json'
      security [bearer_auth: []]

      parameter name: :id, in: :path, type: :string, format: :uuid, required: true,
                description: 'Booking ID'

      response '200', 'booking cancelled' do
        schema type: :object,
               properties: {
                 data: {
                   type: :object,
                   properties: {
                     id: { type: :string, format: :uuid },
                     reference: { type: :string },
                     status: { type: :string, enum: ['cancelled'] },
                     seat_released: { type: :boolean }
                   }
                 }
               }

        let(:booking_record) { create(:booking, api_key: api_key, status: 'confirmed') }
        let(:id) { booking_record.id }

        run_test!
      end

      response '422', 'already cancelled' do
        schema '$ref': '#/components/schemas/Error'

        let(:booking_record) { create(:booking, api_key: api_key, status: 'cancelled') }
        let(:id) { booking_record.id }

        run_test!
      end

      response '403', 'forbidden' do
        schema '$ref': '#/components/schemas/Error'

        let(:other_booking) { create(:booking) }
        let(:id) { other_booking.id }

        run_test!
      end

      response '404', 'booking not found' do
        schema '$ref': '#/components/schemas/Error'

        let(:id) { 'non-existent-id' }

        run_test!
      end

      response '401', 'unauthorized' do
        schema '$ref': '#/components/schemas/Error'

        let(:id) { create(:booking).id }
        let(:Authorization) { 'Bearer invalid_token' }

        run_test!
      end
    end
  end
end

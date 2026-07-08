require 'rails_helper'

RSpec.describe 'Api::V1::Bookings', type: :request do
  let(:api_key) { create(:api_key) }
  let(:headers) { auth_headers(api_key) }

  describe 'POST /api/v1/bookings' do
    let(:flight) { create(:flight, :scheduled) }
    let(:seat) { create(:seat, flight: flight, is_available: true) }

    context 'without authentication' do
      it 'returns 401 unauthorized' do
        post '/api/v1/bookings', params: {
          flight_id: flight.id,
          seat_id: seat.id,
          passenger_name: 'John Doe'
        }

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'with authentication' do
      it 'creates a booking successfully' do
        post '/api/v1/bookings', params: {
          flight_id: flight.id,
          seat_id: seat.id,
          passenger_name: 'John Doe'
        }, headers: headers

        expect(response).to have_http_status(:created)
        expect(json_response['data']['reference']).to be_present
        expect(json_response['data']['passenger_name']).to eq('John Doe')
        expect(json_response['data']['status']).to eq('confirmed')
      end

      it 'marks the seat as unavailable' do
        post '/api/v1/bookings', params: {
          flight_id: flight.id,
          seat_id: seat.id,
          passenger_name: 'John Doe'
        }, headers: headers

        seat.reload
        expect(seat.is_available).to be false
      end

      context 'when flight is cancelled' do
        let(:flight) { create(:flight, :cancelled) }

        it 'returns FLIGHT_CANCELLED error' do
          post '/api/v1/bookings', params: {
            flight_id: flight.id,
            seat_id: seat.id,
            passenger_name: 'John Doe'
          }, headers: headers

          expect(response).to have_http_status(:unprocessable_entity)
          expect(json_response['code']).to eq('FLIGHT_CANCELLED')
        end
      end

      context 'when flight is diverted' do
        let(:flight) { create(:flight, :diverted) }

        it 'returns FLIGHT_DIVERTED error' do
          post '/api/v1/bookings', params: {
            flight_id: flight.id,
            seat_id: seat.id,
            passenger_name: 'John Doe'
          }, headers: headers

          expect(response).to have_http_status(:unprocessable_entity)
          expect(json_response['code']).to eq('FLIGHT_DIVERTED')
        end
      end

      context 'when seat is taken' do
        let(:seat) { create(:seat, flight: flight, is_available: false) }

        it 'returns SEAT_TAKEN error' do
          post '/api/v1/bookings', params: {
            flight_id: flight.id,
            seat_id: seat.id,
            passenger_name: 'John Doe'
          }, headers: headers

          expect(response).to have_http_status(:conflict)
          expect(json_response['code']).to eq('SEAT_TAKEN')
        end
      end

      context 'when user already has a booking on the flight' do
        before do
          other_seat = create(:seat, flight: flight, is_available: true)
          create(:booking, api_key: api_key, flight: flight, seat: other_seat, status: 'confirmed')
        end

        it 'returns DUPLICATE_BOOKING error' do
          post '/api/v1/bookings', params: {
            flight_id: flight.id,
            seat_id: seat.id,
            passenger_name: 'John Doe'
          }, headers: headers

          expect(response).to have_http_status(:unprocessable_entity)
          expect(json_response['code']).to eq('DUPLICATE_BOOKING')
          expect(json_response['details']).to have_key('existing_reference')
        end
      end

      context 'when flight or seat not found' do
        it 'returns NOT_FOUND for non-existent flight' do
          post '/api/v1/bookings', params: {
            flight_id: 'non-existent',
            seat_id: seat.id,
            passenger_name: 'John Doe'
          }, headers: headers

          expect(response).to have_http_status(:not_found)
          expect(json_response['code']).to eq('NOT_FOUND')
        end
      end

      context 'with validation error' do
        it 'returns VALIDATION_ERROR for missing passenger_name' do
          post '/api/v1/bookings', params: {
            flight_id: flight.id,
            seat_id: seat.id,
            passenger_name: ''
          }, headers: headers

          expect(response).to have_http_status(:unprocessable_entity)
          expect(json_response['code']).to eq('VALIDATION_ERROR')
        end
      end
    end
  end

  describe 'GET /api/v1/bookings' do
    context 'without authentication' do
      it 'returns 401 unauthorized' do
        get '/api/v1/bookings'

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'with authentication' do
      let!(:booking1) { create(:booking, api_key: api_key) }
      let!(:booking2) { create(:booking, api_key: api_key) }
      let!(:other_booking) { create(:booking) } # belongs to different api_key

      it 'returns only bookings for current api_key' do
        get '/api/v1/bookings', headers: headers

        expect(response).to have_http_status(:ok)
        expect(json_response['data'].length).to eq(2)

        references = json_response['data'].map { |b| b['reference'] }
        expect(references).to include(booking1.reference, booking2.reference)
        expect(references).not_to include(other_booking.reference)
      end

      it 'includes flight and seat details' do
        get '/api/v1/bookings', headers: headers

        booking_data = json_response['data'].first
        expect(booking_data['flight']).to include('flight_number', 'origin', 'destination')
        expect(booking_data['seat']).to include('seat_number', 'seat_class')
      end
    end
  end

  describe 'GET /api/v1/bookings/:id' do
    let(:booking) { create(:booking, api_key: api_key) }

    context 'without authentication' do
      it 'returns 401 unauthorized' do
        get "/api/v1/bookings/#{booking.id}"

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'with authentication' do
      it 'returns the booking' do
        get "/api/v1/bookings/#{booking.id}", headers: headers

        expect(response).to have_http_status(:ok)
        expect(json_response['data']['id']).to eq(booking.id)
        expect(json_response['data']['reference']).to eq(booking.reference)
      end

      context 'when booking belongs to another user' do
        let(:other_booking) { create(:booking) }

        it 'returns FORBIDDEN error' do
          get "/api/v1/bookings/#{other_booking.id}", headers: headers

          expect(response).to have_http_status(:forbidden)
          expect(json_response['code']).to eq('FORBIDDEN')
        end
      end

      context 'when booking not found' do
        it 'returns NOT_FOUND error' do
          get '/api/v1/bookings/non-existent-id', headers: headers

          expect(response).to have_http_status(:not_found)
          expect(json_response['code']).to eq('NOT_FOUND')
        end
      end
    end
  end

  describe 'DELETE /api/v1/bookings/:id' do
    let(:flight) { create(:flight) }
    let(:seat) { create(:seat, flight: flight, is_available: false) }
    let!(:booking) { create(:booking, api_key: api_key, flight: flight, seat: seat, status: 'confirmed') }

    context 'without authentication' do
      it 'returns 401 unauthorized' do
        delete "/api/v1/bookings/#{booking.id}"

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'with authentication' do
      it 'cancels the booking' do
        delete "/api/v1/bookings/#{booking.id}", headers: headers

        expect(response).to have_http_status(:ok)
        expect(json_response['data']['status']).to eq('cancelled')
        expect(json_response['data']['seat_released']).to be true

        booking.reload
        expect(booking.status).to eq('cancelled')
      end

      it 'releases the seat' do
        delete "/api/v1/bookings/#{booking.id}", headers: headers

        seat.reload
        expect(seat.is_available).to be true
      end

      context 'when booking is already cancelled' do
        before { booking.update!(status: 'cancelled') }

        it 'returns ALREADY_CANCELLED error' do
          delete "/api/v1/bookings/#{booking.id}", headers: headers

          expect(response).to have_http_status(:unprocessable_entity)
          expect(json_response['code']).to eq('ALREADY_CANCELLED')
        end
      end

      context 'when booking belongs to another user' do
        let(:other_booking) { create(:booking) }

        it 'returns FORBIDDEN error' do
          delete "/api/v1/bookings/#{other_booking.id}", headers: headers

          expect(response).to have_http_status(:forbidden)
          expect(json_response['code']).to eq('FORBIDDEN')
        end
      end

      context 'when booking not found' do
        it 'returns NOT_FOUND error' do
          delete '/api/v1/bookings/non-existent-id', headers: headers

          expect(response).to have_http_status(:not_found)
          expect(json_response['code']).to eq('NOT_FOUND')
        end
      end
    end
  end
end

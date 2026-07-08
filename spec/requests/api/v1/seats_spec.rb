require 'rails_helper'

RSpec.describe 'Api::V1::Seats', type: :request do
  let(:api_key) { create(:api_key) }
  let(:headers) { auth_headers(api_key) }

  describe 'GET /api/v1/flights/:flight_id/seats' do
    context 'without authentication' do
      let(:flight) { create(:flight) }

      it 'returns 401 unauthorized' do
        get "/api/v1/flights/#{flight.id}/seats"

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'with authentication' do
      context 'single deck aircraft' do
        let(:aircraft) { create(:aircraft, :boeing_737) }
        let(:flight) { create(:flight, aircraft: aircraft) }

        before do
          # Create seats for different classes
          create(:seat, flight: flight, seat_class: 'first', seat_number: '1A', row: 1, deck: 'main')
          create(:seat, flight: flight, seat_class: 'business', seat_number: '3A', row: 3, deck: 'main')
          create(:seat, flight: flight, seat_class: 'comfort_plus', seat_number: '10A', row: 10, deck: 'main')
          create(:seat, flight: flight, seat_class: 'economy', seat_number: '20A', row: 20, deck: 'main')
          create(:seat, flight: flight, seat_class: 'economy', seat_number: '20B', row: 20, deck: 'main', is_available: false)
        end

        it 'returns seat map with all classes' do
          get "/api/v1/flights/#{flight.id}/seats", headers: headers

          expect(response).to have_http_status(:ok)
          expect(json_response['data']['seat_map']).to include('first', 'business', 'comfort_plus', 'economy')
        end

        it 'returns single deck format' do
          get "/api/v1/flights/#{flight.id}/seats", headers: headers

          expect(json_response['data']['is_double_deck']).to be false
          expect(json_response['data']['seat_map']).not_to include('upper_deck', 'main_deck')
        end

        it 'includes summary with availability counts' do
          get "/api/v1/flights/#{flight.id}/seats", headers: headers

          summary = json_response['data']['summary']
          expect(summary['total']).to eq(5)
          expect(summary['available']).to eq(4)
          expect(summary['taken']).to eq(1)
          expect(summary['by_class']).to include('economy', 'business', 'first')
        end

        describe 'filtering' do
          it 'filters by seat class' do
            get "/api/v1/flights/#{flight.id}/seats", params: { class: 'economy' }, headers: headers

            seat_map = json_response['data']['seat_map']
            # When filtering, only matching seats should have data
            economy_seats = seat_map['economy']
            expect(economy_seats.length).to eq(2)
          end

          it 'filters by availability' do
            get "/api/v1/flights/#{flight.id}/seats", params: { available: 'true' }, headers: headers

            all_seats = json_response['data']['seat_map'].values.flatten
            expect(all_seats).to all(include('is_available' => true))
          end

          it 'filters by seat type' do
            create(:seat, flight: flight, seat_class: 'economy', seat_type: 'aisle', seat_number: '21C')

            get "/api/v1/flights/#{flight.id}/seats", params: { type: 'aisle' }, headers: headers

            all_seats = json_response['data']['seat_map'].values.flatten
            expect(all_seats).to all(include('seat_type' => 'aisle'))
          end

          it 'filters by deck' do
            get "/api/v1/flights/#{flight.id}/seats", params: { deck: 'main' }, headers: headers

            all_seats = json_response['data']['seat_map'].values.flatten
            expect(all_seats).to all(include('deck' => 'main'))
          end
        end
      end

      context 'double deck aircraft (A380)' do
        let(:aircraft) { create(:aircraft, :airbus_a380) }
        let(:flight) { create(:flight, aircraft: aircraft) }

        before do
          # Upper deck seats
          create(:seat, flight: flight, seat_class: 'first', deck: 'upper', seat_number: '1A')
          create(:seat, flight: flight, seat_class: 'business', deck: 'upper', seat_number: '5A')

          # Main deck seats
          create(:seat, flight: flight, seat_class: 'comfort_plus', deck: 'main', seat_number: '20A')
          create(:seat, flight: flight, seat_class: 'economy', deck: 'main', seat_number: '30A')
        end

        it 'returns double deck format' do
          get "/api/v1/flights/#{flight.id}/seats", headers: headers

          expect(json_response['data']['is_double_deck']).to be true
          expect(json_response['data']['seat_map']).to include('upper_deck', 'main_deck')
        end

        it 'organizes seats by deck' do
          get "/api/v1/flights/#{flight.id}/seats", headers: headers

          seat_map = json_response['data']['seat_map']
          expect(seat_map['upper_deck']).to include('first', 'business')
          expect(seat_map['main_deck']).to include('comfort_plus', 'economy')
        end
      end

      context 'non-existent flight' do
        it 'returns 404' do
          get '/api/v1/flights/non-existent-id/seats', headers: headers

          expect(response).to have_http_status(:not_found)
          expect(json_response['code']).to eq('NOT_FOUND')
        end
      end
    end
  end

  describe 'GET /api/v1/flights/:flight_id/seats/:id' do
    let(:flight) { create(:flight, economy_price_cents: 15000) }
    let(:seat) { create(:seat, flight: flight, seat_class: 'economy', seat_number: '15A') }

    context 'without authentication' do
      it 'returns 401 unauthorized' do
        get "/api/v1/flights/#{flight.id}/seats/#{seat.id}"

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'with authentication' do
      it 'returns the seat details' do
        get "/api/v1/flights/#{flight.id}/seats/#{seat.id}", headers: headers

        expect(response).to have_http_status(:ok)
        expect(json_response['data']['id']).to eq(seat.id)
        expect(json_response['data']['seat_number']).to eq('15A')
      end

      it 'includes seat class and type' do
        get "/api/v1/flights/#{flight.id}/seats/#{seat.id}", headers: headers

        expect(json_response['data']['seat_class']).to eq('economy')
        expect(json_response['data']['seat_type']).to be_present
      end

      it 'includes price' do
        get "/api/v1/flights/#{flight.id}/seats/#{seat.id}", headers: headers

        expect(json_response['data']['price']).to eq(150) # 15000 cents = $150
      end

      it 'returns 404 for non-existent seat' do
        get "/api/v1/flights/#{flight.id}/seats/non-existent-id", headers: headers

        expect(response).to have_http_status(:not_found)
        expect(json_response['code']).to eq('NOT_FOUND')
      end
    end
  end
end

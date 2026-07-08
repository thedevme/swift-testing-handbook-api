require 'rails_helper'

RSpec.describe 'Api::V1::Flights', type: :request do
  let(:api_key) { create(:api_key) }
  let(:headers) { auth_headers(api_key) }

  describe 'GET /api/v1/flights' do
    context 'without authentication' do
      it 'returns 401 unauthorized' do
        get '/api/v1/flights'

        expect(response).to have_http_status(:unauthorized)
        expect(json_response['code']).to eq('UNAUTHORIZED')
      end
    end

    context 'with authentication' do
      let!(:tpa) { create(:airport, :tpa) }
      let!(:jfk) { create(:airport, :jfk) }
      let!(:lax) { create(:airport, :lax) }
      let!(:route_tpa_jfk) { create(:route, origin: tpa, destination: jfk) }
      let!(:route_jfk_lax) { create(:route, origin: jfk, destination: lax) }

      let!(:flight1) { create(:flight, route: route_tpa_jfk, economy_price_cents: 15000, status: 'scheduled') }
      let!(:flight2) { create(:flight, route: route_tpa_jfk, economy_price_cents: 20000, status: 'on_time') }
      let!(:flight3) { create(:flight, route: route_jfk_lax, economy_price_cents: 25000, status: 'delayed') }

      it 'returns all flights' do
        get '/api/v1/flights', headers: headers

        expect(response).to have_http_status(:ok)
        expect(json_response['data'].length).to eq(3)
      end

      it 'includes pagination meta' do
        get '/api/v1/flights', headers: headers

        expect(json_response['meta']).to include('total', 'page', 'per_page', 'total_pages')
        expect(json_response['meta']['total']).to eq(3)
      end

      describe 'filtering' do
        it 'filters by origin' do
          get '/api/v1/flights', params: { origin: 'TPA' }, headers: headers

          expect(json_response['data'].length).to eq(2)
          json_response['data'].each do |flight|
            expect(flight['origin']['code']).to eq('TPA')
          end
        end

        it 'filters by destination' do
          get '/api/v1/flights', params: { destination: 'LAX' }, headers: headers

          expect(json_response['data'].length).to eq(1)
          expect(json_response['data'][0]['destination']['code']).to eq('LAX')
        end

        it 'filters by status' do
          get '/api/v1/flights', params: { status: 'delayed' }, headers: headers

          expect(json_response['data'].length).to eq(1)
          expect(json_response['data'][0]['status']).to eq('delayed')
        end

        it 'filters by date' do
          today = Date.current
          flight1.update!(scheduled_departure_at: today.beginning_of_day + 8.hours)
          flight2.update!(scheduled_departure_at: (today + 1.day).beginning_of_day + 8.hours)

          get '/api/v1/flights', params: { date: today.to_s }, headers: headers

          departures = json_response['data'].map { |f| Date.parse(f['departure_at']) }
          expect(departures).to all(eq(today))
        end
      end

      describe 'sorting' do
        it 'sorts by price ascending' do
          get '/api/v1/flights', params: { sort: 'price_asc' }, headers: headers

          prices = json_response['data'].map { |f| f['pricing']['economy'] }
          expect(prices).to eq(prices.sort)
        end

        it 'sorts by price descending' do
          get '/api/v1/flights', params: { sort: 'price_desc' }, headers: headers

          prices = json_response['data'].map { |f| f['pricing']['economy'] }
          expect(prices).to eq(prices.sort.reverse)
        end

        it 'sorts by duration' do
          flight1.update!(duration_minutes: 300)
          flight2.update!(duration_minutes: 100)
          flight3.update!(duration_minutes: 200)

          get '/api/v1/flights', params: { sort: 'duration' }, headers: headers

          durations = json_response['data'].map { |f| f['duration_minutes'] }
          expect(durations).to eq(durations.sort)
        end

        it 'defaults to departure time sorting' do
          flight1.update!(scheduled_departure_at: 3.hours.from_now)
          flight2.update!(scheduled_departure_at: 1.hour.from_now)
          flight3.update!(scheduled_departure_at: 2.hours.from_now)

          get '/api/v1/flights', headers: headers

          departures = json_response['data'].map { |f| Time.parse(f['departure_at']) }
          expect(departures).to eq(departures.sort)
        end
      end

      describe 'pagination' do
        before { create_list(:flight, 25, route: route_tpa_jfk) }

        it 'defaults to 20 per page' do
          get '/api/v1/flights', headers: headers

          expect(json_response['data'].length).to eq(20)
          expect(json_response['meta']['per_page']).to eq(20)
        end

        it 'respects per_page parameter' do
          get '/api/v1/flights', params: { per_page: 10 }, headers: headers

          expect(json_response['data'].length).to eq(10)
        end

        it 'caps per_page at 100' do
          get '/api/v1/flights', params: { per_page: 200 }, headers: headers

          expect(json_response['meta']['per_page']).to eq(100)
        end

        it 'paginates correctly' do
          get '/api/v1/flights', params: { page: 2, per_page: 10 }, headers: headers

          expect(json_response['meta']['page']).to eq(2)
          expect(json_response['data'].length).to eq(10)
        end
      end
    end
  end

  describe 'GET /api/v1/flights/:id' do
    let(:flight) { create(:flight, :with_seats) }

    context 'without authentication' do
      it 'returns 401 unauthorized' do
        get "/api/v1/flights/#{flight.id}"

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'with authentication' do
      it 'returns the flight' do
        get "/api/v1/flights/#{flight.id}", headers: headers

        expect(response).to have_http_status(:ok)
        expect(json_response['data']['id']).to eq(flight.id)
        expect(json_response['data']['flight_number']).to eq(flight.flight_number)
      end

      it 'includes origin and destination' do
        get "/api/v1/flights/#{flight.id}", headers: headers

        expect(json_response['data']['origin']).to include('code', 'name', 'city')
        expect(json_response['data']['destination']).to include('code', 'name', 'city')
      end

      it 'includes pricing' do
        get "/api/v1/flights/#{flight.id}", headers: headers

        expect(json_response['data']['pricing']).to include('economy', 'comfort_plus')
      end

      it 'includes aircraft info' do
        get "/api/v1/flights/#{flight.id}", headers: headers

        expect(json_response['data']['aircraft']).to include('model', 'aisle_type')
      end

      it 'returns 404 for non-existent flight' do
        get '/api/v1/flights/non-existent-id', headers: headers

        expect(response).to have_http_status(:not_found)
        expect(json_response['code']).to eq('NOT_FOUND')
      end
    end
  end
end

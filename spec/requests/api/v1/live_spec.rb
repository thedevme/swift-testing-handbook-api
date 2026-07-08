require 'rails_helper'

RSpec.describe 'Api::V1::Live', type: :request do
  let(:api_key) { create(:api_key) }
  let(:headers) { auth_headers(api_key) }

  describe 'GET /api/v1/live/flights' do
    context 'without authentication' do
      it 'returns 401 unauthorized' do
        get '/api/v1/live/flights'

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'with authentication' do
      let(:tpa) { create(:airport, :tpa) }
      let(:jfk) { create(:airport, :jfk) }
      let(:route) { create(:route, origin: tpa, destination: jfk) }

      let!(:in_air_flight) do
        create(:flight, :in_air, route: route)
      end

      let!(:scheduled_flight) do
        create(:flight, :scheduled, route: route)
      end

      let!(:arrived_flight) do
        create(:flight, :arrived, route: route)
      end

      it 'returns only flights currently in air' do
        get '/api/v1/live/flights', headers: headers

        expect(response).to have_http_status(:ok)
        flight_ids = json_response['data'].map { |f| f['id'] }
        expect(flight_ids).to include(in_air_flight.id)
        expect(flight_ids).not_to include(scheduled_flight.id)
        expect(flight_ids).not_to include(arrived_flight.id)
      end

      it 'includes meta with flight count' do
        get '/api/v1/live/flights', headers: headers

        expect(json_response['meta']['flights_in_air']).to eq(1)
        expect(json_response['meta']['generated_at']).to be_present
      end

      it 'includes position data' do
        get '/api/v1/live/flights', headers: headers

        flight_data = json_response['data'].first
        expect(flight_data['position']).to include('lat', 'lng')
        expect(flight_data['progress_pct']).to be_a(Integer)
      end

      it 'returns empty array when no flights in air' do
        Flight.destroy_all

        get '/api/v1/live/flights', headers: headers

        expect(json_response['data']).to eq([])
        expect(json_response['meta']['flights_in_air']).to eq(0)
      end
    end
  end

  describe 'GET /api/v1/live/flights/:id' do
    context 'without authentication' do
      let(:flight) { create(:flight, :in_air) }

      it 'returns 401 unauthorized' do
        get "/api/v1/live/flights/#{flight.id}"

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'with authentication' do
      let(:tpa) { create(:airport, :tpa) }
      let(:jfk) { create(:airport, :jfk) }
      let(:route) { create(:route, origin: tpa, destination: jfk) }

      context 'when flight is in air' do
        let(:flight) { create(:flight, :in_air, route: route) }

        it 'returns detailed flight data' do
          get "/api/v1/live/flights/#{flight.id}", headers: headers

          expect(response).to have_http_status(:ok)
          expect(json_response['data']['id']).to eq(flight.id)
        end

        it 'includes position and time remaining' do
          get "/api/v1/live/flights/#{flight.id}", headers: headers

          data = json_response['data']
          expect(data['position']).to include('lat', 'lng')
          expect(data['time_remaining_min']).to be_a(Integer)
          expect(data['progress_pct']).to be_a(Integer)
        end

        it 'includes detailed origin and destination' do
          get "/api/v1/live/flights/#{flight.id}", headers: headers

          data = json_response['data']
          expect(data['origin']).to include('code', 'city')
          expect(data['destination']).to include('code', 'city')
        end

        it 'includes aircraft model' do
          get "/api/v1/live/flights/#{flight.id}", headers: headers

          expect(json_response['data']['aircraft']).to be_present
        end
      end

      context 'when flight is not in air' do
        let(:scheduled_flight) { create(:flight, :scheduled) }

        it 'returns NOT_IN_AIR error' do
          get "/api/v1/live/flights/#{scheduled_flight.id}", headers: headers

          expect(response).to have_http_status(:unprocessable_entity)
          expect(json_response['code']).to eq('NOT_IN_AIR')
        end
      end

      context 'when flight not found' do
        it 'returns NOT_FOUND error' do
          get '/api/v1/live/flights/non-existent-id', headers: headers

          expect(response).to have_http_status(:not_found)
          expect(json_response['code']).to eq('NOT_FOUND')
        end
      end
    end
  end

  describe 'GET /api/v1/live/stats' do
    context 'without authentication' do
      it 'returns 401 unauthorized' do
        get '/api/v1/live/stats'

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'with authentication' do
      before do
        create(:flight, :in_air)
        create(:flight, :in_air)
        create(:flight, :on_time)
        create(:flight, :on_time)
        create(:flight, :on_time)
        create(:flight, :delayed)
        create(:flight, :cancelled)
        create(:flight, :scheduled) # Not counted in on_time calculation
      end

      it 'returns flights_in_air count' do
        get '/api/v1/live/stats', headers: headers

        expect(response).to have_http_status(:ok)
        expect(json_response['data']['flights_in_air']).to eq(2)
      end

      it 'calculates on_time percentage' do
        get '/api/v1/live/stats', headers: headers

        # 5 flights have status != scheduled (3 on_time, 1 delayed, 1 cancelled, 2 departed for in_air)
        # Actually 3 on_time out of 7 non-scheduled = ~43%
        expect(json_response['data']['on_time_pct']).to be_a(Integer)
      end

      it 'returns delayed count' do
        get '/api/v1/live/stats', headers: headers

        expect(json_response['data']['delayed_count']).to eq(1)
      end

      it 'returns cancelled count' do
        get '/api/v1/live/stats', headers: headers

        expect(json_response['data']['cancelled_today']).to eq(1)
      end

      it 'returns busiest route' do
        get '/api/v1/live/stats', headers: headers

        # Busiest route should be a string like "TPA → JFK" or nil
        busiest = json_response['data']['busiest_route']
        expect(busiest).to be_nil.or(match(/\w{3} → \w{3}/))
      end

      it 'includes reset_at timestamp' do
        get '/api/v1/live/stats', headers: headers

        expect(json_response['data']['reset_at']).to be_present
        reset_time = Time.parse(json_response['data']['reset_at'])
        expect(reset_time).to be > Time.current
      end

      context 'with no flights' do
        before { Flight.destroy_all }

        it 'returns zero counts' do
          get '/api/v1/live/stats', headers: headers

          expect(json_response['data']['flights_in_air']).to eq(0)
          expect(json_response['data']['on_time_pct']).to eq(0)
          expect(json_response['data']['delayed_count']).to eq(0)
        end
      end
    end
  end
end

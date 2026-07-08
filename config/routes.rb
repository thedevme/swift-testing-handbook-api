Rails.application.routes.draw do
  # API Documentation
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'

  # Gumroad webhook
  post '/gumroad/ping', to: 'gumroad#ping'

  namespace :api do
    namespace :v1 do
      # API Keys
      post '/keys', to: 'keys#create'
      post '/keys/recover', to: 'keys#recover'

      # Flights
      get '/flights/round_trip', to: 'flights#round_trip'
      post '/flights/multi_city/search', to: 'multi_city#search'
      resources :flights, only: [:index, :show] do
        resources :seats, only: [:index, :show]
      end

      # Bookings
      post '/round_trip_bookings', to: 'round_trip_bookings#create'
      resources :bookings, only: [:index, :show, :create, :destroy]

      # Multi-city itineraries
      resources :itineraries, only: [:index, :show, :create, :destroy]

      # Live flights
      get '/live/flights', to: 'live#index'
      get '/live/flights/:id', to: 'live#show'
      get '/live/stats', to: 'live#stats'

      # Weather
      get '/weather', to: 'weather#index'
      get '/weather/forecast', to: 'weather#forecast'

      # Airlines
      resources :airlines, only: [:index, :show]
    end
  end

  # Health check
  get '/health', to: proc { [200, {}, ['ok']] }
  get 'up' => 'rails/health#show', as: :rails_health_check
end

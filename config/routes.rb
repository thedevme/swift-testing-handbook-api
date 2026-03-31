Rails.application.routes.draw do
  # Gumroad webhook
  post '/gumroad/ping', to: 'gumroad#ping'

  namespace :api do
    namespace :v1 do
      # Key recovery
      post '/keys/recover', to: 'keys#recover'

      # Flights
      resources :flights, only: [:index, :show] do
        resources :seats, only: [:index, :show]
      end

      # Bookings
      resources :bookings, only: [:index, :show, :create, :destroy]

      # Live flights
      get '/live/flights', to: 'live#index'
      get '/live/flights/:id', to: 'live#show'
      get '/live/stats', to: 'live#stats'
    end
  end

  # Health check
  get '/health', to: proc { [200, {}, ['ok']] }
  get 'up' => 'rails/health#show', as: :rails_health_check
end

# SkyBook API - Build Phases

This document outlines the implementation phases for building the SkyBook Flight API, a companion API for the Swift Testing Handbook.

## Table of Contents

- [Phase 1: Rails Setup](#phase-1-rails-setup)
- [Phase 2: PostgreSQL Configuration](#phase-2-postgresql-configuration)
- [Phase 3: UUID Primary Keys](#phase-3-uuid-primary-keys)
- [Phase 4: Aircraft Model](#phase-4-aircraft-model)
- [Phase 5: Airport Model](#phase-5-airport-model)
- [Phase 6: Route Model](#phase-6-route-model)
- [Phase 7: Flight Model](#phase-7-flight-model)
- [Phase 8: Seat Model](#phase-8-seat-model)
- [Phase 9: API Key Authentication](#phase-9-api-key-authentication)
- [Phase 10: Gumroad Webhook](#phase-10-gumroad-webhook)
- [Phase 11: Booking Model](#phase-11-booking-model)
- [Phase 12: Flights Controller](#phase-12-flights-controller)
- [Phase 13: Seats Controller](#phase-13-seats-controller)
- [Phase 14: Bookings Controller](#phase-14-bookings-controller)
- [Phase 15: Live Tracking Controller](#phase-15-live-tracking-controller)
- [Phase 16: Serializers](#phase-16-serializers)
- [Phase 17: Rate Limiting](#phase-17-rate-limiting)
- [Phase 18: Scheduled Tasks](#phase-18-scheduled-tasks)
- [Phase 19: Email Configuration](#phase-19-email-configuration)
- [Phase 20: Key Recovery](#phase-20-key-recovery)
- [Phase 21: Testing](#phase-21-testing)
- [Phase 22: API Documentation](#phase-22-api-documentation)
- [Phase 23: Deployment](#phase-23-deployment)

---

## Phase 1: Rails Setup

### Create API-Only Rails Application

```bash
rails new swift-testing-handbook-api --api --database=postgresql
cd swift-testing-handbook-api
```

### Configure Gemfile

Add essential gems:

```ruby
# Gemfile
gem "rack-cors"        # CORS handling
gem "rack-attack"      # Rate limiting
gem "clockwork"        # Scheduled tasks
gem "sendgrid-ruby"    # Email delivery

group :development, :test do
  gem "rspec-rails"
  gem "factory_bot_rails"
  gem "faker"
  gem "rswag-api"
  gem "rswag-ui"
  gem "rswag-specs"
end

group :development do
  gem "letter_opener"  # Email preview
end
```

```bash
bundle install
```

---

## Phase 2: PostgreSQL Configuration

### Configure Database

```yaml
# config/database.yml
default: &default
  adapter: postgresql
  encoding: unicode
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>

development:
  <<: *default
  database: skybook_development

test:
  <<: *default
  database: skybook_test

production:
  <<: *default
  url: <%= ENV['DATABASE_URL'] %>
```

```bash
rails db:create
```

---

## Phase 3: UUID Primary Keys

### Configure UUID as Default Primary Key

```ruby
# config/initializers/generators.rb
Rails.application.config.generators do |g|
  g.orm :active_record, primary_key_type: :uuid
end
```

### Enable UUID Extension

```bash
rails g migration EnableUuidExtension
```

```ruby
# db/migrate/xxx_enable_uuid_extension.rb
class EnableUuidExtension < ActiveRecord::Migration[8.1]
  def change
    enable_extension 'pgcrypto' unless extension_enabled?('pgcrypto')
  end
end
```

---

## Phase 4: Aircraft Model

### Generate Migration

```bash
rails g model Aircraft model:string economy_seats:integer comfort_plus_seats:integer business_seats:integer first_seats:integer total_seats:integer aisle_type:string
```

### Configure Model

```ruby
# app/models/aircraft.rb
class Aircraft < ApplicationRecord
  self.table_name = 'aircraft'

  has_many :routes
  has_many :flights

  validates :model, presence: true
  validates :economy_seats, :comfort_plus_seats, :business_seats, :total_seats,
            presence: true, numericality: { greater_than_or_equal_to: 0 }
end
```

### Aircraft Types

| Model | Economy | C+ | Business | First | Total | Aisle |
|-------|---------|-----|----------|-------|-------|-------|
| Boeing 737-800 | 126 | 36 | 16 | 0 | 178 | single |
| Boeing 757-200 | 168 | 44 | 24 | 0 | 236 | single |
| Boeing 767-300ER | 175 | 35 | 26 | 0 | 236 | twin |
| Boeing 777-200LR | 218 | 48 | 52 | 8 | 326 | twin |
| Airbus A320 | 120 | 36 | 12 | 0 | 168 | single |
| Airbus A330-300 | 211 | 40 | 34 | 0 | 285 | twin |
| Airbus A380-800 | 301 | 60 | 76 | 14 | 451 | twin |

---

## Phase 5: Airport Model

### Generate Migration

```bash
rails g model Airport code:string name:string city:string country:string latitude:decimal longitude:decimal is_international:boolean
```

### Configure Model

```ruby
# app/models/airport.rb
class Airport < ApplicationRecord
  has_many :departing_routes, class_name: 'Route', foreign_key: :origin_id
  has_many :arriving_routes, class_name: 'Route', foreign_key: :destination_id

  validates :code, presence: true, uniqueness: true, length: { is: 3 }
  validates :name, :city, :country, presence: true
  validates :latitude, :longitude, presence: true

  COORDINATES = {
    "TPA" => { lat: 27.9755, lng: -82.5332 },
    "JFK" => { lat: 40.6413, lng: -73.7781 },
    # ... 18 more airports
  }.freeze
end
```

### Airport Data

**US Domestic:**
- TPA (Tampa), JFK (New York), LAX (Los Angeles), ORD (Chicago)
- BOS (Boston), MIA (Miami), SEA (Seattle), DEN (Denver)
- ATL (Atlanta), DFW (Dallas)

**International:**
- LHR (London), CDG (Paris), NRT (Tokyo), SYD (Sydney)
- DXB (Dubai), YYZ (Toronto), MEX (Mexico City), AMS (Amsterdam)
- SIN (Singapore), GRU (São Paulo)

---

## Phase 6: Route Model

### Generate Migration

```bash
rails g model Route origin:references destination:references aircraft:references duration_minutes:integer departures_per_day:integer flight_number_prefix:string is_international:boolean
```

### Configure Model

```ruby
# app/models/route.rb
class Route < ApplicationRecord
  belongs_to :origin, class_name: 'Airport'
  belongs_to :destination, class_name: 'Airport'
  belongs_to :aircraft

  has_many :flights

  validates :duration_minutes, :departures_per_day, presence: true
  validates :flight_number_prefix, presence: true
end
```

### Add Unique Index

```ruby
add_index :routes, [:origin_id, :destination_id], unique: true
```

---

## Phase 7: Flight Model

### Generate Migration

```bash
rails g model Flight route:references aircraft:references flight_number:string scheduled_departure_at:datetime scheduled_arrival_at:datetime economy_price_cents:integer comfort_plus_price_cents:integer business_price_cents:integer first_price_cents:integer status:string delay_minutes:integer diverted_to:string duration_minutes:integer
```

### Configure Model

```ruby
# app/models/flight.rb
class Flight < ApplicationRecord
  belongs_to :route
  belongs_to :aircraft

  has_many :seats, dependent: :destroy
  has_many :bookings

  enum :status, {
    scheduled: 'scheduled',
    on_time: 'on_time',
    delayed: 'delayed',
    boarding: 'boarding',
    departed: 'departed',
    arrived: 'arrived',
    cancelled: 'cancelled',
    diverted: 'diverted'
  }

  validates :flight_number, presence: true
  validates :scheduled_departure_at, :scheduled_arrival_at, presence: true
  validates :economy_price_cents, :comfort_plus_price_cents,
            presence: true, numericality: { greater_than: 0 }

  scope :bookable, -> { where.not(status: [:cancelled, :diverted, :departed, :arrived]) }

  delegate :origin, :destination, to: :route

  def in_air?
    now = Time.current
    now >= scheduled_departure_at && now <= scheduled_arrival_at && !cancelled? && !diverted?
  end

  def current_position
    return nil unless in_air?
    # Linear interpolation between origin and destination
  end

  def time_remaining_minutes
    return nil unless in_air?
    ((scheduled_arrival_at - Time.current) / 60).round
  end
end
```

---

## Phase 8: Seat Model

### Generate Migration

```bash
rails g model Seat flight:references seat_number:string row:integer column_letter:string deck:string seat_class:string seat_type:string is_available:boolean features:string
```

### Configure Model

```ruby
# app/models/seat.rb
class Seat < ApplicationRecord
  belongs_to :flight
  has_one :booking

  enum :seat_class, {
    economy: 'economy',
    comfort_plus: 'comfort_plus',
    business: 'business',
    first_class: 'first'
  }

  enum :seat_type, {
    window: 'window',
    middle: 'middle',
    aisle: 'aisle'
  }, prefix: true

  validates :seat_number, presence: true
  validates :seat_number, uniqueness: { scope: :flight_id }

  scope :available, -> { where(is_available: true) }
  scope :on_deck, ->(deck) { where(deck: deck) }

  def price_cents
    case seat_class
    when 'economy' then flight.economy_price_cents
    when 'comfort_plus' then flight.comfort_plus_price_cents
    when 'business' then flight.business_price_cents
    when 'first' then flight.first_price_cents
    end
  end
end
```

---

## Phase 9: API Key Authentication

### Generate Migration

```bash
rails g model ApiKey email:string token:string
```

### Configure Model

```ruby
# app/models/api_key.rb
class ApiKey < ApplicationRecord
  has_many :bookings

  validates :email, presence: true, uniqueness: true
  validates :token, presence: true, uniqueness: true

  before_validation :generate_token, on: :create

  private

  def generate_token
    self.token ||= "sk_#{SecureRandom.hex(16)}"
  end
end
```

### Configure Application Controller

```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::API
  before_action :authenticate_reader

  private

  def authenticate_reader
    token = request.headers['Authorization']&.sub('Bearer ', '')
    @current_api_key = ApiKey.find_by(token: token)

    unless @current_api_key
      render json: { error: 'UNAUTHORIZED', message: 'Valid API key required' }, status: :unauthorized
    end
  end

  def current_api_key
    @current_api_key
  end
end
```

---

## Phase 10: Gumroad Webhook

### Create Controller

```ruby
# app/controllers/gumroad_controller.rb
class GumroadController < ApplicationController
  skip_before_action :authenticate_reader

  def ping
    return head :ok if params[:test] == 'true'
    return head :ok if Purchase.exists?(order_number: params[:order_number])

    ActiveRecord::Base.transaction do
      Purchase.create!(
        email: params[:email],
        order_number: params[:order_number],
        product_id: params[:product_id],
        price_cents: params[:price].to_i,
        purchased_at: Time.current
      )

      api_key = ApiKey.find_or_create_by!(email: params[:email])
      ApiKeyMailer.welcome(params[:email], api_key.token).deliver_later
    end

    head :ok
  rescue => e
    render json: { error: e.message }, status: :bad_request
  end
end
```

### Add Route

```ruby
post '/gumroad/ping', to: 'gumroad#ping'
```

---

## Phase 11: Booking Model

### Generate Migration

```bash
rails g model Booking api_key:references flight:references seat:references reference:string passenger_name:string status:string
```

### Configure Model

```ruby
# app/models/booking.rb
class Booking < ApplicationRecord
  belongs_to :api_key
  belongs_to :flight
  belongs_to :seat

  enum :status, { confirmed: 'confirmed', cancelled: 'cancelled' }

  validates :passenger_name, presence: true, length: { maximum: 100 }
  validates :reference, presence: true, uniqueness: true

  before_validation :generate_reference, on: :create
  after_create :mark_seat_unavailable
  after_update :release_seat, if: :cancelled?

  private

  def generate_reference
    self.reference ||= loop do
      ref = "#{flight.flight_number[0..1]}#{SecureRandom.alphanumeric(4).upcase}"
      break ref unless Booking.exists?(reference: ref)
    end
  end

  def mark_seat_unavailable
    seat.update!(is_available: false)
  end

  def release_seat
    seat.update!(is_available: true) if saved_change_to_status? && cancelled?
  end
end
```

### Add Unique Index

```ruby
add_index :bookings, [:api_key_id, :flight_id], unique: true, where: "status = 'confirmed'"
```

---

## Phase 12: Flights Controller

### Create Controller

```ruby
# app/controllers/api/v1/flights_controller.rb
module Api
  module V1
    class FlightsController < ApplicationController
      def index
        flights = Flight.includes(:route, :aircraft, :seats, route: [:origin, :destination])

        # Apply filters
        flights = flights.joins(route: :origin).where(airports: { code: params[:origin] }) if params[:origin]
        flights = flights.joins(route: :destination).where(airports: { code: params[:destination] }) if params[:destination]
        flights = flights.where(status: params[:status]) if params[:status]

        # Apply date filter
        if params[:date]
          date = Date.parse(params[:date])
          flights = flights.where(scheduled_departure_at: date.beginning_of_day..date.end_of_day)
        end

        # Apply sorting and pagination
        flights = apply_sort(flights)
        total_count = flights.count
        flights = paginate(flights)

        render json: {
          data: flights.map { |f| FlightSerializer.new(f).as_json },
          meta: pagination_meta(total_count)
        }
      end

      def show
        flight = Flight.includes(:route, :aircraft, :seats, route: [:origin, :destination]).find(params[:id])
        render json: { data: FlightSerializer.new(flight).as_json }
      rescue ActiveRecord::RecordNotFound
        render_error(code: 'NOT_FOUND', message: 'Flight not found', status: :not_found)
      end
    end
  end
end
```

---

## Phase 13: Seats Controller

### Create Controller

```ruby
# app/controllers/api/v1/seats_controller.rb
module Api
  module V1
    class SeatsController < ApplicationController
      before_action :set_flight

      def index
        seats = @flight.seats

        # Apply filters
        seats = seats.where(seat_class: params[:class]) if params[:class]
        seats = seats.available if params[:available] == 'true'
        seats = seats.where(seat_type: params[:type]) if params[:type]
        seats = seats.on_deck(params[:deck]) if params[:deck]

        # Build seat map (single or double deck)
        is_double_deck = @flight.aircraft.model.include?('A380')
        seat_map = is_double_deck ? build_double_deck_map(seats) : build_single_deck_map(seats)

        render json: {
          data: {
            flight_id: @flight.id,
            flight_number: @flight.flight_number,
            aircraft: @flight.aircraft.model,
            is_double_deck: is_double_deck,
            seat_map: seat_map,
            summary: build_summary
          }
        }
      end

      def show
        seat = @flight.seats.find(params[:id])
        render json: { data: SeatSerializer.new(seat).as_json }
      end
    end
  end
end
```

---

## Phase 14: Bookings Controller

### Create Controller

```ruby
# app/controllers/api/v1/bookings_controller.rb
module Api
  module V1
    class BookingsController < ApplicationController
      def create
        flight = Flight.find(params[:flight_id])
        seat = flight.seats.find(params[:seat_id])

        # Validation checks
        return render_error(code: 'FLIGHT_CANCELLED', ...) if flight.cancelled?
        return render_error(code: 'FLIGHT_DIVERTED', ...) if flight.diverted?
        return render_error(code: 'SEAT_TAKEN', ...) unless seat.is_available?

        # Check for duplicate booking
        existing = current_api_key.bookings.confirmed.find_by(flight: flight)
        return render_error(code: 'DUPLICATE_BOOKING', ...) if existing

        booking = current_api_key.bookings.create!(
          flight: flight,
          seat: seat,
          passenger_name: params[:passenger_name]
        )

        render json: { data: BookingSerializer.new(booking).as_json }, status: :created
      end

      def index
        bookings = current_api_key.bookings.includes(:flight, :seat)
        render json: { data: bookings.map { |b| BookingSerializer.new(b).as_json } }
      end

      def show
        booking = Booking.find(params[:id])
        return render_error(code: 'FORBIDDEN', ...) unless booking.api_key_id == current_api_key.id
        render json: { data: BookingSerializer.new(booking).as_json }
      end

      def destroy
        booking = Booking.find(params[:id])
        return render_error(code: 'FORBIDDEN', ...) unless booking.api_key_id == current_api_key.id
        return render_error(code: 'ALREADY_CANCELLED', ...) if booking.cancelled?

        booking.cancelled!
        render json: { data: { id: booking.id, status: 'cancelled', seat_released: true } }
      end
    end
  end
end
```

---

## Phase 15: Live Tracking Controller

### Create Controller

```ruby
# app/controllers/api/v1/live_controller.rb
module Api
  module V1
    class LiveController < ApplicationController
      def index
        flights = Flight.includes(:route, :aircraft, route: [:origin, :destination])
                        .select(&:in_air?)

        render json: {
          data: flights.map { |f| LiveFlightSerializer.new(f).as_json },
          meta: { flights_in_air: flights.count, generated_at: Time.current.iso8601 }
        }
      end

      def show
        flight = Flight.find(params[:id])
        return render_error(code: 'NOT_IN_AIR', ...) unless flight.in_air?

        render json: { data: LiveFlightSerializer.new(flight, detailed: true).as_json }
      end

      def stats
        flights = Flight.all

        render json: {
          data: {
            flights_in_air: flights.select(&:in_air?).count,
            on_time_pct: calculate_on_time_percentage(flights),
            delayed_count: flights.delayed.count,
            cancelled_today: flights.cancelled.count,
            busiest_route: busiest_route,
            reset_at: next_reset_time.iso8601
          }
        }
      end
    end
  end
end
```

---

## Phase 16: Serializers

### Flight Serializer

```ruby
# app/serializers/flight_serializer.rb
class FlightSerializer
  def initialize(flight)
    @flight = flight
  end

  def as_json
    {
      id: @flight.id,
      flight_number: @flight.flight_number,
      origin: airport_json(@flight.origin),
      destination: airport_json(@flight.destination),
      departure_at: @flight.scheduled_departure_at.iso8601,
      arrival_at: @flight.scheduled_arrival_at.iso8601,
      duration_minutes: @flight.duration_minutes,
      status: @flight.status,
      aircraft: aircraft_json,
      pricing: pricing_json,
      seats_available: seats_summary
    }
  end
end
```

### Other Serializers

- `SeatSerializer` - seat details with price calculation
- `BookingSerializer` - booking with flight and seat info
- `LiveFlightSerializer` - in-air flight with position data

---

## Phase 17: Rate Limiting

### Configure Rack::Attack

```ruby
# config/initializers/rack_attack.rb
class Rack::Attack
  throttle('api/v1', limit: 100, period: 1.minute) do |req|
    if req.path.start_with?('/api/')
      req.get_header('HTTP_AUTHORIZATION')&.sub('Bearer ', '')
    end
  end

  self.throttled_responder = lambda do |request|
    [
      429,
      { 'Content-Type' => 'application/json' },
      [{ error: 'RATE_LIMITED', message: 'Too many requests' }.to_json]
    ]
  end
end
```

---

## Phase 18: Scheduled Tasks

### Configure Clockwork

```ruby
# lib/clock.rb
require 'clockwork'
require './config/boot'
require './config/environment'

module Clockwork
  every(1.day, 'generate_flights', at: '00:00') do
    FlightGeneratorJob.perform_later
  end

  every(1.week, 'randomize_seats', at: 'Sunday 00:00') do
    SeatRandomizerJob.perform_later
  end
end
```

### Create Jobs

```ruby
# app/jobs/flight_generator_job.rb
class FlightGeneratorJob < ApplicationJob
  queue_as :default

  def perform
    # Generate flights for the next 7 days
    Route.find_each do |route|
      route.departures_per_day.times do |i|
        # Create flight with seats
      end
    end
  end
end
```

---

## Phase 19: Email Configuration

### SendGrid Setup

```ruby
# config/initializers/sendgrid.rb
if Rails.env.production? && ENV['SENDGRID_API_KEY'].present?
  ActionMailer::Base.delivery_method = :smtp
  ActionMailer::Base.smtp_settings = {
    address: 'smtp.sendgrid.net',
    port: 587,
    domain: 'swifttestinghandbook.com',
    user_name: 'apikey',
    password: ENV['SENDGRID_API_KEY'],
    authentication: :plain,
    enable_starttls_auto: true
  }
end
```

### Environment Variables

```
SENDGRID_API_KEY=SG.xxx
SENDGRID_FROM_EMAIL=api@swifttestinghandbook.com
```

---

## Phase 20: Key Recovery

### Create Mailer

```ruby
# app/mailers/api_key_mailer.rb
class ApiKeyMailer < ApplicationMailer
  def welcome(email, token)
    @token = token
    mail(to: email, subject: 'Your SkyBook API Key')
  end
end
```

### Create Controller

```ruby
# app/controllers/api/v1/keys_controller.rb
module Api
  module V1
    class KeysController < ApplicationController
      skip_before_action :authenticate_reader

      def recover
        email = params[:email]&.downcase&.strip

        if email.present?
          key = ApiKey.find_by(email: email)
          ApiKeyMailer.welcome(email, key.token).deliver_later if key
        end

        # Always return same response (no user enumeration)
        render json: { message: "If this email is on file, we've sent the API key to it." }
      end
    end
  end
end
```

---

## Phase 21: Testing

### Setup RSpec

```bash
rails generate rspec:install
```

### Create Factories

```ruby
# spec/factories/
# - aircraft.rb (7 aircraft types)
# - airports.rb (20 airports with coordinates)
# - api_keys.rb (auto-generated tokens)
# - routes.rb (with associations)
# - flights.rb (with status traits)
# - seats.rb (with class/type traits)
# - bookings.rb (with reference generation)
# - purchases.rb (Gumroad records)
```

### Test Coverage

- **Model specs**: Validations, associations, callbacks, scopes, methods
- **Request specs**: Authentication, filtering, pagination, error handling
- **Integration specs**: Full API workflow tests

---

## Phase 22: API Documentation

### Setup rswag

```bash
rails generate rswag:install
```

### Configure swagger_helper

```ruby
# spec/swagger_helper.rb
RSpec.configure do |config|
  config.openapi_specs = {
    'v1/swagger.yaml' => {
      openapi: '3.0.1',
      info: { title: 'SkyBook Flight API', version: 'v1' },
      components: {
        securitySchemes: {
          bearer_auth: { type: :http, scheme: :bearer }
        }
      }
    }
  }
end
```

### Generate Swagger

```bash
rails rswag:specs:swaggerize
```

### Access Documentation

Visit `/api-docs` to see interactive API documentation.

---

## Phase 23: Deployment

### Docker Configuration

```dockerfile
# Dockerfile
FROM ruby:3.3-slim

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential libpq-dev

WORKDIR /rails
COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .
RUN bundle exec bootsnap precompile --gemfile app/ lib/

CMD ["./bin/rails", "server"]
```

### Kamal Deployment

```yaml
# config/deploy.yml
service: skybook-api
image: your-registry/skybook-api

servers:
  web:
    hosts:
      - your-server.com

env:
  clear:
    RAILS_ENV: production
  secret:
    - RAILS_MASTER_KEY
    - DATABASE_URL
    - SENDGRID_API_KEY
```

### Deploy

```bash
kamal setup
kamal deploy
```

---

## API Endpoints Summary

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | /gumroad/ping | Gumroad webhook |
| POST | /api/v1/keys/recover | API key recovery |
| GET | /api/v1/flights | List flights |
| GET | /api/v1/flights/:id | Get flight details |
| GET | /api/v1/flights/:id/seats | Get seat map |
| GET | /api/v1/flights/:id/seats/:id | Get seat details |
| GET | /api/v1/bookings | List user bookings |
| POST | /api/v1/bookings | Create booking |
| GET | /api/v1/bookings/:id | Get booking details |
| DELETE | /api/v1/bookings/:id | Cancel booking |
| GET | /api/v1/live/flights | List flights in air |
| GET | /api/v1/live/flights/:id | Get live flight data |
| GET | /api/v1/live/stats | Get airline stats |

---

## Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| DATABASE_URL | PostgreSQL connection string | Production |
| RAILS_MASTER_KEY | Rails credentials key | Production |
| SENDGRID_API_KEY | SendGrid API key | Production |
| SENDGRID_FROM_EMAIL | From email address | Optional |
| RAILS_LOG_LEVEL | Log level (info/debug) | Optional |

---

## Maintenance Notes

### Weekly Tasks
- Seat availability randomizes every Sunday at midnight UTC

### Daily Tasks
- New flights generated for upcoming dates
- Stats reset at midnight UTC

### Monitoring
- Rate limiting: 100 requests/minute per API key
- Health check: GET /health or GET /up

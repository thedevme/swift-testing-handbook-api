require 'rails_helper'

RSpec.describe Flight, type: :model do
  describe 'validations' do
    subject { build(:flight) }

    it { is_expected.to validate_presence_of(:flight_number) }
    it { is_expected.to validate_presence_of(:scheduled_departure_at) }
    it { is_expected.to validate_presence_of(:scheduled_arrival_at) }
    it { is_expected.to validate_presence_of(:economy_price_cents) }
    it { is_expected.to validate_presence_of(:comfort_plus_price_cents) }

    it { is_expected.to validate_numericality_of(:economy_price_cents).is_greater_than(0) }
    it { is_expected.to validate_numericality_of(:comfort_plus_price_cents).is_greater_than(0) }

    it 'allows nil business_price_cents' do
      flight = build(:flight, business_price_cents: nil)
      expect(flight).to be_valid
    end

    it 'allows nil first_price_cents' do
      flight = build(:flight, first_price_cents: nil)
      expect(flight).to be_valid
    end
  end

  describe 'associations' do
    it { is_expected.to belong_to(:route) }
    it { is_expected.to belong_to(:aircraft) }
    it { is_expected.to have_many(:seats).dependent(:destroy) }
    it { is_expected.to have_many(:bookings) }
  end

  describe 'enums' do
    it 'defines status enum' do
      expect(Flight.statuses.keys).to match_array(
        %w[scheduled on_time delayed boarding departed arrived cancelled diverted]
      )
    end
  end

  describe 'delegations' do
    let(:route) { create(:route, :tpa_to_jfk) }
    let(:flight) { create(:flight, route: route) }

    it 'delegates origin to route' do
      expect(flight.origin).to eq(route.origin)
    end

    it 'delegates destination to route' do
      expect(flight.destination).to eq(route.destination)
    end
  end

  describe '#in_air?' do
    it 'returns true when flight is between departure and arrival' do
      flight = build(:flight, :in_air)
      expect(flight.in_air?).to be true
    end

    it 'returns false when flight has not departed' do
      flight = build(:flight,
                     scheduled_departure_at: 2.hours.from_now,
                     scheduled_arrival_at: 5.hours.from_now)
      expect(flight.in_air?).to be false
    end

    it 'returns false when flight has arrived' do
      flight = build(:flight,
                     scheduled_departure_at: 5.hours.ago,
                     scheduled_arrival_at: 2.hours.ago)
      expect(flight.in_air?).to be false
    end

    it 'returns false when flight is cancelled' do
      flight = build(:flight, :in_air, status: 'cancelled')
      expect(flight.in_air?).to be false
    end

    it 'returns false when flight is diverted' do
      flight = build(:flight, :in_air, status: 'diverted', diverted_to: 'BOS')
      expect(flight.in_air?).to be false
    end
  end

  describe '#current_position' do
    let(:tpa) { create(:airport, :tpa) }
    let(:jfk) { create(:airport, :jfk) }
    let(:route) { create(:route, origin: tpa, destination: jfk) }

    it 'returns nil when not in air' do
      flight = create(:flight, route: route, scheduled_departure_at: 2.hours.from_now)
      expect(flight.current_position).to be_nil
    end

    it 'returns position hash when in air' do
      flight = create(:flight,
                      route: route,
                      scheduled_departure_at: 1.hour.ago,
                      scheduled_arrival_at: 2.hours.from_now)

      position = flight.current_position

      expect(position).to be_a(Hash)
      expect(position).to have_key(:lat)
      expect(position).to have_key(:lng)
      expect(position).to have_key(:progress_pct)
    end

    it 'calculates correct progress percentage' do
      # 2 hours into a 4 hour flight = 50%
      flight = create(:flight,
                      route: route,
                      scheduled_departure_at: 2.hours.ago,
                      scheduled_arrival_at: 2.hours.from_now)

      position = flight.current_position
      expect(position[:progress_pct]).to be_within(5).of(50)
    end

    it 'interpolates lat/lng based on progress' do
      # Halfway through flight
      flight = create(:flight,
                      route: route,
                      scheduled_departure_at: 2.hours.ago,
                      scheduled_arrival_at: 2.hours.from_now)

      position = flight.current_position

      tpa_lat = Airport::COORDINATES['TPA'][:lat]
      jfk_lat = Airport::COORDINATES['JFK'][:lat]
      midpoint_lat = (tpa_lat + jfk_lat) / 2

      expect(position[:lat]).to be_within(2).of(midpoint_lat)
    end
  end

  describe '#time_remaining_minutes' do
    it 'returns nil when not in air' do
      flight = build(:flight, scheduled_departure_at: 2.hours.from_now)
      expect(flight.time_remaining_minutes).to be_nil
    end

    it 'returns remaining minutes when in air' do
      flight = build(:flight,
                     scheduled_departure_at: 1.hour.ago,
                     scheduled_arrival_at: 2.hours.from_now)

      expect(flight.time_remaining_minutes).to be_within(1).of(120)
    end
  end

  describe 'scopes' do
    describe '.bookable' do
      before do
        create(:flight, :scheduled)
        create(:flight, :on_time)
        create(:flight, :delayed)
        create(:flight, :boarding)
        create(:flight, :departed)
        create(:flight, :arrived)
        create(:flight, :cancelled)
        create(:flight, :diverted)
      end

      it 'excludes cancelled flights' do
        expect(Flight.bookable.cancelled).to be_empty
      end

      it 'excludes diverted flights' do
        expect(Flight.bookable.diverted).to be_empty
      end

      it 'excludes departed flights' do
        expect(Flight.bookable.departed).to be_empty
      end

      it 'excludes arrived flights' do
        expect(Flight.bookable.arrived).to be_empty
      end

      it 'includes scheduled, on_time, delayed, and boarding flights' do
        bookable_statuses = Flight.bookable.pluck(:status).uniq
        expect(bookable_statuses).to match_array(%w[scheduled on_time delayed boarding])
      end
    end
  end

  describe 'factory traits' do
    it 'creates in_air flight' do
      flight = create(:flight, :in_air)
      expect(flight.in_air?).to be true
    end

    it 'creates flight with seats' do
      flight = create(:flight, :with_seats)
      expect(flight.seats.count).to be > 0
      expect(flight.seats.economy.count).to be > 0
      expect(flight.seats.business.count).to be > 0
    end
  end
end

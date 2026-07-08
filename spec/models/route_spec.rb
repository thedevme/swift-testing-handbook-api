require 'rails_helper'

RSpec.describe Route, type: :model do
  describe 'validations' do
    subject { build(:route) }

    it { is_expected.to validate_presence_of(:duration_minutes) }
    it { is_expected.to validate_presence_of(:departures_per_day) }
    it { is_expected.to validate_presence_of(:flight_number_prefix) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:origin).class_name('Airport') }
    it { is_expected.to belong_to(:destination).class_name('Airport') }
    it { is_expected.to belong_to(:aircraft) }
    it { is_expected.to have_many(:flights) }
  end

  describe 'factory traits' do
    it 'creates domestic route' do
      route = create(:route, :domestic)
      expect(route.is_international).to be false
      expect(route.duration_minutes).to eq(150)
    end

    it 'creates international route' do
      route = create(:route, :international)
      expect(route.is_international).to be true
      expect(route.duration_minutes).to eq(480)
    end

    it 'creates TPA to JFK route' do
      route = create(:route, :tpa_to_jfk)
      expect(route.origin.code).to eq('TPA')
      expect(route.destination.code).to eq('JFK')
      expect(route.flight_number_prefix).to eq('SK10')
    end
  end

  describe 'route attributes' do
    let(:origin) { create(:airport, :tpa) }
    let(:destination) { create(:airport, :jfk) }
    let(:aircraft) { create(:aircraft, :boeing_737) }

    it 'creates valid route with all attributes' do
      route = Route.create!(
        origin: origin,
        destination: destination,
        aircraft: aircraft,
        duration_minutes: 165,
        departures_per_day: 6,
        flight_number_prefix: 'SK10',
        is_international: false
      )

      expect(route).to be_valid
      expect(route.origin.code).to eq('TPA')
      expect(route.destination.code).to eq('JFK')
    end
  end
end

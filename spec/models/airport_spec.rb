require 'rails_helper'

RSpec.describe Airport, type: :model do
  describe 'validations' do
    subject { build(:airport) }

    it { is_expected.to validate_presence_of(:code) }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:city) }
    it { is_expected.to validate_presence_of(:country) }
    it { is_expected.to validate_presence_of(:latitude) }
    it { is_expected.to validate_presence_of(:longitude) }

    it { is_expected.to validate_uniqueness_of(:code) }
    it { is_expected.to validate_length_of(:code).is_equal_to(3) }

    it 'requires exactly 3 character code' do
      airport = build(:airport, code: 'AB')
      expect(airport).not_to be_valid
      expect(airport.errors[:code]).to include('is the wrong length (should be 3 characters)')

      airport.code = 'ABCD'
      expect(airport).not_to be_valid

      airport.code = 'ABC'
      expect(airport).to be_valid
    end
  end

  describe 'associations' do
    it { is_expected.to have_many(:departing_routes).class_name('Route').with_foreign_key(:origin_id) }
    it { is_expected.to have_many(:arriving_routes).class_name('Route').with_foreign_key(:destination_id) }
  end

  describe 'COORDINATES constant' do
    it 'contains 20 airports' do
      expect(Airport::COORDINATES.keys.count).to eq(20)
    end

    it 'includes major US airports' do
      us_airports = %w[TPA JFK LAX ORD BOS MIA SEA DEN ATL DFW]
      us_airports.each do |code|
        expect(Airport::COORDINATES).to have_key(code)
      end
    end

    it 'includes major international airports' do
      intl_airports = %w[LHR CDG NRT SYD DXB YYZ MEX AMS SIN GRU]
      intl_airports.each do |code|
        expect(Airport::COORDINATES).to have_key(code)
      end
    end

    it 'has valid lat/lng for each airport' do
      Airport::COORDINATES.each do |code, coords|
        expect(coords).to have_key(:lat), "#{code} missing lat"
        expect(coords).to have_key(:lng), "#{code} missing lng"
        expect(coords[:lat]).to be_a(Numeric), "#{code} lat is not numeric"
        expect(coords[:lng]).to be_a(Numeric), "#{code} lng is not numeric"
        expect(coords[:lat]).to be_between(-90, 90), "#{code} lat out of range"
        expect(coords[:lng]).to be_between(-180, 180), "#{code} lng out of range"
      end
    end

    it 'has correct coordinates for TPA' do
      expect(Airport::COORDINATES['TPA'][:lat]).to eq(27.9755)
      expect(Airport::COORDINATES['TPA'][:lng]).to eq(-82.5332)
    end

    it 'has correct coordinates for JFK' do
      expect(Airport::COORDINATES['JFK'][:lat]).to eq(40.6413)
      expect(Airport::COORDINATES['JFK'][:lng]).to eq(-73.7781)
    end

    it 'is frozen' do
      expect(Airport::COORDINATES).to be_frozen
    end
  end

  describe 'factory traits' do
    it 'creates TPA with correct data' do
      airport = create(:airport, :tpa)
      expect(airport.code).to eq('TPA')
      expect(airport.city).to eq('Tampa')
      expect(airport.latitude).to eq(27.9755)
    end

    it 'creates international airport' do
      airport = create(:airport, :lhr)
      expect(airport.code).to eq('LHR')
      expect(airport.is_international).to be true
    end
  end
end

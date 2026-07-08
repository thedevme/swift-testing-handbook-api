require 'rails_helper'

RSpec.describe Aircraft, type: :model do
  describe 'validations' do
    subject { build(:aircraft) }

    it { is_expected.to validate_presence_of(:model) }
    it { is_expected.to validate_presence_of(:economy_seats) }
    it { is_expected.to validate_presence_of(:comfort_plus_seats) }
    it { is_expected.to validate_presence_of(:business_seats) }
    it { is_expected.to validate_presence_of(:total_seats) }

    it { is_expected.to validate_numericality_of(:economy_seats).is_greater_than_or_equal_to(0) }
    it { is_expected.to validate_numericality_of(:comfort_plus_seats).is_greater_than_or_equal_to(0) }
    it { is_expected.to validate_numericality_of(:business_seats).is_greater_than_or_equal_to(0) }
    it { is_expected.to validate_numericality_of(:total_seats).is_greater_than_or_equal_to(0) }
  end

  describe 'associations' do
    it { is_expected.to have_many(:routes) }
    it { is_expected.to have_many(:flights) }
  end

  describe 'factory traits' do
    it 'creates a valid Boeing 737' do
      aircraft = create(:aircraft, :boeing_737)
      expect(aircraft.model).to eq('Boeing 737-800')
      expect(aircraft.aisle_type).to eq('single')
      expect(aircraft.total_seats).to eq(178)
    end

    it 'creates a valid Airbus A380 with double deck' do
      aircraft = create(:aircraft, :airbus_a380)
      expect(aircraft.model).to eq('Airbus A380-800')
      expect(aircraft.aisle_type).to eq('twin')
      expect(aircraft.first_seats).to eq(14)
      expect(aircraft.total_seats).to eq(451)
    end

    it 'creates aircraft with first class' do
      aircraft = create(:aircraft, :with_first_class)
      expect(aircraft.first_seats).to eq(8)
    end
  end

  describe 'seat counts' do
    let(:aircraft) { create(:aircraft, :boeing_777) }

    it 'has correct seat distribution' do
      expect(aircraft.economy_seats).to eq(218)
      expect(aircraft.comfort_plus_seats).to eq(48)
      expect(aircraft.business_seats).to eq(52)
      expect(aircraft.first_seats).to eq(8)
    end

    it 'total equals sum of all classes' do
      calculated_total = aircraft.economy_seats +
                         aircraft.comfort_plus_seats +
                         aircraft.business_seats +
                         aircraft.first_seats
      expect(aircraft.total_seats).to eq(calculated_total)
    end
  end
end

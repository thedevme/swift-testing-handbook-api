require 'rails_helper'

RSpec.describe Booking, type: :model do
  describe 'validations' do
    let(:flight) { create(:flight) }
    let(:seat) { create(:seat, flight: flight) }
    let(:api_key) { create(:api_key) }
    subject { build(:booking, flight: flight, seat: seat, api_key: api_key) }

    it { is_expected.to validate_presence_of(:passenger_name) }
    it { is_expected.to validate_length_of(:passenger_name).is_at_most(100) }
    # Reference is auto-generated, so we test its behavior separately
  end

  describe 'associations' do
    let(:flight) { create(:flight) }
    let(:seat) { create(:seat, flight: flight) }
    let(:api_key) { create(:api_key) }

    it 'belongs to api_key' do
      booking = create(:booking, flight: flight, seat: seat, api_key: api_key)
      expect(booking.api_key).to eq(api_key)
    end

    it 'belongs to flight' do
      booking = create(:booking, flight: flight, seat: seat, api_key: api_key)
      expect(booking.flight).to eq(flight)
    end

    it 'belongs to seat' do
      booking = create(:booking, flight: flight, seat: seat, api_key: api_key)
      expect(booking.seat).to eq(seat)
    end
  end

  describe 'enums' do
    it 'defines status enum' do
      expect(Booking.statuses.keys).to match_array(%w[confirmed cancelled])
    end
  end

  describe 'reference generation' do
    let(:flight) { create(:flight, flight_number: 'SK1234') }
    let(:seat) { create(:seat, flight: flight) }
    let(:api_key) { create(:api_key) }

    it 'auto-generates reference on create' do
      booking = Booking.new(
        api_key: api_key,
        flight: flight,
        seat: seat,
        passenger_name: 'John Doe'
      )

      expect(booking.reference).to be_nil
      booking.valid?
      expect(booking.reference).to be_present
    end

    it 'generates 6-character reference' do
      booking = create(:booking, flight: flight, seat: seat)
      expect(booking.reference.length).to eq(6)
    end

    it 'starts with first 2 chars of flight number' do
      booking = create(:booking, flight: flight, seat: seat)
      expect(booking.reference).to start_with('SK')
    end

    it 'generates unique references' do
      references = 10.times.map do
        create(:booking, flight: flight, seat: create(:seat, flight: flight)).reference
      end
      expect(references.uniq.count).to eq(10)
    end

    it 'does not override existing reference' do
      booking = Booking.new(
        api_key: api_key,
        flight: flight,
        seat: seat,
        passenger_name: 'John Doe',
        reference: 'CUSTOM'
      )
      booking.valid?
      expect(booking.reference).to eq('CUSTOM')
    end
  end

  describe 'seat availability callbacks' do
    let(:flight) { create(:flight) }
    let(:seat) { create(:seat, flight: flight, is_available: true) }
    let(:api_key) { create(:api_key) }

    describe 'after_create :mark_seat_unavailable' do
      it 'marks seat as unavailable when booking is created' do
        expect(seat.is_available).to be true

        create(:booking, flight: flight, seat: seat, api_key: api_key)

        seat.reload
        expect(seat.is_available).to be false
      end
    end

    describe 'after_update :release_seat' do
      let!(:booking) do
        create(:booking, flight: flight, seat: seat, api_key: api_key, status: 'confirmed')
      end

      it 'releases seat when booking is cancelled' do
        expect(seat.reload.is_available).to be false

        booking.cancelled!

        expect(seat.reload.is_available).to be true
      end

      it 'does not release seat for non-status updates' do
        seat.reload
        expect(seat.is_available).to be false

        booking.update!(passenger_name: 'New Name')

        expect(seat.reload.is_available).to be false
      end
    end
  end

  describe 'factory traits' do
    it 'creates confirmed booking' do
      booking = create(:booking, :confirmed)
      expect(booking.status).to eq('confirmed')
    end

    it 'creates cancelled booking' do
      booking = create(:booking, :cancelled)
      expect(booking.status).to eq('cancelled')
    end
  end
end

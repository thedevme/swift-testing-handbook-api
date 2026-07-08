require 'rails_helper'

RSpec.describe Purchase, type: :model do
  describe 'validations' do
    subject { build(:purchase) }

    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_presence_of(:order_number) }
    it { is_expected.to validate_presence_of(:purchased_at) }
    it { is_expected.to validate_uniqueness_of(:order_number) }
  end

  describe 'order_number uniqueness' do
    it 'prevents duplicate order numbers' do
      create(:purchase, order_number: 'ORDER-123')
      duplicate = build(:purchase, order_number: 'ORDER-123')

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:order_number]).to include('has already been taken')
    end

    it 'allows different order numbers' do
      create(:purchase, order_number: 'ORDER-123')
      different = build(:purchase, order_number: 'ORDER-456')

      expect(different).to be_valid
    end
  end

  describe 'factory' do
    it 'creates valid purchase' do
      purchase = create(:purchase)

      expect(purchase).to be_valid
      expect(purchase.email).to be_present
      expect(purchase.order_number).to be_present
      expect(purchase.purchased_at).to be_present
    end

    it 'creates purchase with recent timestamp' do
      purchase = create(:purchase, :recent)
      expect(purchase.purchased_at).to be_within(1.day).of(1.day.ago)
    end

    it 'creates purchase with old timestamp' do
      purchase = create(:purchase, :old)
      expect(purchase.purchased_at).to be_within(1.day).of(1.year.ago)
    end
  end

  describe 'optional fields' do
    it 'allows nil product_id' do
      purchase = build(:purchase, product_id: nil)
      expect(purchase).to be_valid
    end

    it 'allows nil price_cents' do
      purchase = build(:purchase, price_cents: nil)
      expect(purchase).to be_valid
    end
  end
end

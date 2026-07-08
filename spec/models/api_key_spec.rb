require 'rails_helper'

RSpec.describe ApiKey, type: :model do
  describe 'validations' do
    subject { create(:api_key) }

    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email) }
    # Token is auto-generated, so we test its behavior separately
  end

  describe 'associations' do
    it { is_expected.to have_many(:bookings) }
  end

  describe 'token generation' do
    it 'auto-generates token on create' do
      api_key = ApiKey.new(email: 'test@example.com')
      expect(api_key.token).to be_nil

      api_key.valid?
      expect(api_key.token).to be_present
    end

    it 'generates token with sk_ prefix' do
      api_key = create(:api_key)
      expect(api_key.token).to start_with('sk_')
    end

    it 'generates 35-character token (sk_ + 32 hex chars)' do
      api_key = create(:api_key)
      expect(api_key.token.length).to eq(35)
    end

    it 'generates unique tokens' do
      tokens = 10.times.map { create(:api_key).token }
      expect(tokens.uniq.count).to eq(10)
    end

    it 'does not override existing token' do
      api_key = ApiKey.new(email: 'test@example.com', token: 'sk_custom_token_12345678901234')
      api_key.valid?
      expect(api_key.token).to eq('sk_custom_token_12345678901234')
    end
  end

  describe 'email uniqueness' do
    it 'prevents duplicate emails' do
      create(:api_key, email: 'duplicate@example.com')
      duplicate = build(:api_key, email: 'duplicate@example.com')

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:email]).to include('has already been taken')
    end
  end
end

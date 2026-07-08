require 'rails_helper'

RSpec.describe 'Api::V1::Keys', type: :request do
  describe 'POST /api/v1/keys/recover' do
    it 'does not require authentication' do
      post '/api/v1/keys/recover', params: { email: 'test@example.com' }

      expect(response).not_to have_http_status(:unauthorized)
    end

    context 'with existing email' do
      let!(:api_key) { create(:api_key, email: 'existing@example.com') }

      it 'returns success message' do
        post '/api/v1/keys/recover', params: { email: 'existing@example.com' }

        expect(response).to have_http_status(:ok)
        expect(json_response['message']).to include("If this email is on file")
      end

      it 'sends welcome email' do
        expect {
          post '/api/v1/keys/recover', params: { email: 'existing@example.com' }
        }.to have_enqueued_mail(ApiKeyMailer, :welcome).with(api_key.email, api_key.token)
      end

      it 'handles case-insensitive email' do
        expect {
          post '/api/v1/keys/recover', params: { email: 'EXISTING@EXAMPLE.COM' }
        }.to have_enqueued_mail(ApiKeyMailer, :welcome)
      end

      it 'handles email with whitespace' do
        expect {
          post '/api/v1/keys/recover', params: { email: '  existing@example.com  ' }
        }.to have_enqueued_mail(ApiKeyMailer, :welcome)
      end
    end

    context 'with non-existing email' do
      it 'returns same success message (no user enumeration)' do
        post '/api/v1/keys/recover', params: { email: 'nonexistent@example.com' }

        expect(response).to have_http_status(:ok)
        expect(json_response['message']).to include("If this email is on file")
      end

      it 'does not send email' do
        expect {
          post '/api/v1/keys/recover', params: { email: 'nonexistent@example.com' }
        }.not_to have_enqueued_mail(ApiKeyMailer, :welcome)
      end
    end

    context 'with empty email' do
      it 'returns success message (no error revealed)' do
        post '/api/v1/keys/recover', params: { email: '' }

        expect(response).to have_http_status(:ok)
        expect(json_response['message']).to include("If this email is on file")
      end

      it 'does not send email' do
        expect {
          post '/api/v1/keys/recover', params: { email: '' }
        }.not_to have_enqueued_mail(ApiKeyMailer, :welcome)
      end
    end

    context 'with nil email' do
      it 'returns success message' do
        post '/api/v1/keys/recover', params: {}

        expect(response).to have_http_status(:ok)
      end

      it 'does not send email' do
        expect {
          post '/api/v1/keys/recover', params: {}
        }.not_to have_enqueued_mail(ApiKeyMailer, :welcome)
      end
    end

    describe 'security - no user enumeration' do
      let!(:api_key) { create(:api_key, email: 'secret@example.com') }

      it 'returns identical response for existing and non-existing emails' do
        post '/api/v1/keys/recover', params: { email: 'secret@example.com' }
        existing_response = response.body

        post '/api/v1/keys/recover', params: { email: 'unknown@example.com' }
        unknown_response = response.body

        expect(existing_response).to eq(unknown_response)
      end

      it 'returns identical status codes' do
        post '/api/v1/keys/recover', params: { email: 'secret@example.com' }
        existing_status = response.status

        post '/api/v1/keys/recover', params: { email: 'unknown@example.com' }
        unknown_status = response.status

        expect(existing_status).to eq(unknown_status)
      end
    end
  end
end

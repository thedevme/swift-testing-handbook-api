require 'swagger_helper'

RSpec.describe 'Keys API', type: :request do
  # Note: This endpoint does not require authentication

  path '/api/v1/keys/recover' do
    post 'Recover API key' do
      tags 'Authentication'
      description <<~DESC
        Request recovery of your API key by email.

        If the email is on file, an email will be sent with your API key.
        For security, the response is always the same regardless of whether
        the email exists in our system (no user enumeration).

        **Note:** This endpoint does not require authentication.
      DESC
      consumes 'application/json'
      produces 'application/json'
      security [] # No authentication required

      parameter name: :body, in: :body, schema: {
        type: :object,
        properties: {
          email: { type: :string, format: :email, description: 'Email address associated with your API key' }
        },
        required: ['email']
      }

      response '200', 'recovery email sent (if email exists)' do
        schema type: :object,
               properties: {
                 message: { type: :string, example: "If this email is on file, we've sent the API key to it." }
               }

        let(:body) { { email: 'test@example.com' } }

        run_test!
      end

      response '200', 'response is identical for non-existing email' do
        schema type: :object,
               properties: {
                 message: { type: :string }
               }

        let!(:api_key) { create(:api_key, email: 'exists@example.com') }
        let(:body) { { email: 'nonexistent@example.com' } }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['message']).to include('If this email is on file')
        end
      end
    end
  end
end

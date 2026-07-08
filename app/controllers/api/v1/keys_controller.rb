module Api
  module V1
    class KeysController < ApplicationController
      skip_before_action :authenticate_reader, only: [:create, :recover]

      # POST /api/v1/keys - Create new API key
      def create
        email = params[:email]&.downcase&.strip
        name = params[:name] || params[:reader_name] || 'API User'

        unless email.present?
          return render json: {
            error: 'validation_error',
            message: 'Email is required',
            code: 'VALIDATION_ERROR'
          }, status: :unprocessable_entity
        end

        # Check if email already exists
        existing_key = ApiKey.find_by(email: email)
        if existing_key
          return render json: {
            error: 'duplicate_email',
            message: 'An API key already exists for this email. Use /keys/recover to retrieve it.',
            code: 'DUPLICATE_EMAIL'
          }, status: :conflict
        end

        api_key = ApiKey.create!(
          email: email,
          reader_name: name
        )

        render json: {
          data: {
            token: api_key.token,
            email: api_key.email,
            name: api_key.reader_name,
            created_at: api_key.created_at.iso8601
          }
        }, status: :created

      rescue ActiveRecord::RecordInvalid => e
        render json: {
          error: 'validation_error',
          message: e.message,
          code: 'VALIDATION_ERROR'
        }, status: :unprocessable_entity
      end

      # POST /api/v1/keys/recover
      def recover
        email = params[:email]&.downcase&.strip

        if email.present?
          key = ApiKey.find_by(email: email)
          ApiKeyMailer.welcome(email, key.token).deliver_later if key
        end

        # Always return same response — never reveal if email exists
        render json: {
          message: "If this email is on file, we've sent the API key to it."
        }, status: :ok
      end
    end
  end
end

module Api
  module V1
    class KeysController < ApplicationController
      skip_before_action :authenticate_reader

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

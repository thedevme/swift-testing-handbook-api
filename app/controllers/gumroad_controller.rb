class GumroadController < ApplicationController
  skip_before_action :authenticate_reader

  # POST /gumroad/ping
  def ping
    # Skip test pings
    return head :ok if params[:test] == "true"

    # Idempotent — skip if already processed
    return head :ok if Purchase.exists?(order_number: params[:order_number])

    email = params[:email]&.downcase&.strip
    return head :bad_request unless email.present?

    ActiveRecord::Base.transaction do
      Purchase.create!(
        email: email,
        order_number: params[:order_number],
        product_id: params[:product_id],
        price_cents: (params[:price].to_f * 100).to_i,
        purchased_at: Time.current
      )

      key = ApiKey.find_or_create_by!(email: email)
      ApiKeyMailer.welcome(email, key.token).deliver_later
    end

    head :ok
  end
end

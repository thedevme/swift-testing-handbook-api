# frozen_string_literal: true

# SendGrid SMTP Configuration
#
# Required environment variables:
#   SENDGRID_API_KEY - Your SendGrid API key (starts with SG.)
#   SENDGRID_FROM_EMAIL - Default from email address (optional, defaults to api@swifttestinghandbook.com)
#
# In production, emails are sent via SendGrid SMTP relay.
# In development, letter_opener is used for email previews.
# In test, emails are not delivered.

if Rails.env.production? && ENV['SENDGRID_API_KEY'].present?
  ActionMailer::Base.delivery_method = :smtp
  ActionMailer::Base.smtp_settings = {
    address: 'smtp.sendgrid.net',
    port: 587,
    domain: 'swifttestinghandbook.com',
    user_name: 'apikey', # This is literally the string 'apikey', not a variable
    password: ENV['SENDGRID_API_KEY'],
    authentication: :plain,
    enable_starttls_auto: true
  }
end

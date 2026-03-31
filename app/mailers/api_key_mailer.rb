class ApiKeyMailer < ApplicationMailer
  def welcome(email, token)
    @token = token
    mail(to: email, subject: 'Your SkyBook API Key')
  end
end

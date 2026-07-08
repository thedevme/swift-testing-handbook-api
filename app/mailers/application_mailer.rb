class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch('SENDGRID_FROM_EMAIL', 'api@swifttestinghandbook.com')
  layout "mailer"
end

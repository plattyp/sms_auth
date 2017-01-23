require 'twilio-ruby'

Twilio.configure do |config|
  config.account_sid = SmsAuth::Engine.twilio_account_sid
  config.auth_token = SmsAuth::Engine.twilio_auth_token
end

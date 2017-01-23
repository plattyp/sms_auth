SmsAuth::Engine.setup do |config|
  config.twilio_auth_token = 'TEST_AUTH_TOKEN'
  config.twilio_account_sid = 'TEST_ACCOUNT_SID'
  config.twilio_from_number = '+13122486863'
end

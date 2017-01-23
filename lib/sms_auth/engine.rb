module SmsAuth
  class Engine < ::Rails::Engine
    engine_name 'sms_auth'

    config.generators do |g|
      g.test_framework :rspec
      g.fixture_replacement :factory_girl, dir: 'spec/factories'
    end

    class << self
      mattr_accessor :twilio_auth_token, :twilio_account_sid, :twilio_from_number, :message_prefix,
                     :token_length, :max_login_attempts, :max_login_attempt_within_minutes,
                     :verification_token_time_limit_minutes, :lock_min_duration,
                     :default_token_expiration_days, :limited_recipients

      # Set Default Values
      self.token_length = 6
      self.max_login_attempts = 3
      self.max_login_attempt_within_minutes = 15
      self.verification_token_time_limit_minutes = 5
      self.lock_min_duration = 60
      self.default_token_expiration_days = 90
      self.limited_recipients = []
    end

    def self.setup
      yield self

      # Raise exception if required values are not set
      [:twilio_auth_token, :twilio_account_sid, :twilio_from_number].each do |field|
        if send(field).nil?
          raise Exception, "Missing `#{field}` in initialization"
        end
      end

      # Setup Twilio
      Twilio.configure do |config|
        config.account_sid = twilio_account_sid
        config.auth_token = twilio_auth_token
      end
    end
  end
end

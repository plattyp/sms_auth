require 'rails_helper'

RSpec.describe RegistrationService do
  describe '#register_user' do
    it 'returns false with a specific error message if the phone number is not valid' do
      expect(described_class.new('absdr232').register_user).to eq [false, 'The phone number provided is not valid']
    end

    it 'returns false with a specific error message if the limited recipient list is set and the phone number is not allowed' do
      allow(SmsAuth::Engine).to receive(:limited_recipients) { %w(3125552332) }
      expect(described_class.new('3126652333').register_user).to eq [false, 'The phone number provided is not allowed to be interacted']
    end

    it 'creates a phone_verification for the given phone number and returns true' do
      service = described_class.new('3125555555')
      allow(service).to receive(:send_out_message_synchronously) { double }
      expect(PhoneVerification.find_by_phone_number('3125555555')).to be_nil
      expect(service.register_user).to eq [true, '']
      expect(PhoneVerification.find_by_phone_number('3125555555')).not_to be_nil
    end

    it 'returns false if a verification already exists for the phone_number but its locked' do
      verification = create(:phone_verification, :locked, phone_number: '3125552222')
      service = described_class.new(verification.phone_number)
      allow(service).to receive(:send_out_message_synchronously) { double }
      expect(service.register_user).to eq [false, 'Login attempts have been locked for this phone number. Try again in 60 minutes.']
    end

    it 'sends out a text message to the phone_number and returns true if the verification already existed' do
      verification = create(:phone_verification, phone_number: '3125552333')
      service = described_class.new(verification.phone_number)
      allow(service).to receive(:send_out_message_synchronously) { double }
      expect(service).to receive(:send_out_message_synchronously).exactly(1).times
      expect(service.register_user).to eq [true, '']
    end
  end

  describe '#send_verification_token' do
    before(:each) do
      @verification = create(:phone_verification)
      @service = described_class.new(@verification.phone_number)
    end

    it 'resets the verification token to a different value' do
      allow(@service).to receive(:send_out_message_synchronously) { double }
      expect { @service.send_verification_token(@verification) }.to change { PhoneVerification.find_by_id(@verification.id).verification_token }
    end

    it 'sends the verification token to the phone number initialized' do
      allow(@service).to receive(:send_out_message_synchronously) { double }
      expect(@service).to receive(:send_out_message_synchronously).exactly(1).times
      @service.send_verification_token(@verification)
    end
  end

  describe '#verify_user' do
    it 'calls verification_error if there is something wrong with verification' do
    end

    it 'returns false and an specific error message if the token passed in does not match the one stored for the verification' do
    end

    it 'returns false, an specific error message, and locks the verification if the token passed in does not match and is now above the maximum login attempts' do
    end

    it 'calls create_and_verify_user if the verification does not already have a user associated' do
    end

    it 'returns the last arguement of true if the verification never had a user, but now one was created' do
    end

    it 'returns the last arguement of false if the verification already had a user' do
    end

    it 'creates an authentication token if the token matches successfully' do
    end

    it 'changes the verification token if authenticated successfully' do
    end
  end

  describe '#create_authentication_token' do
    it 'adds an authentication_token for the given user' do
      @user = create(:user)
      expect { described_class.new('3125552333').create_authentication_token(@user.id) }.to change { AuthenticationToken.where(user_id: @user.id).count }.from(0).to(1)
    end
  end

  describe '#verification_invalid?' do
    it 'returns false otherwise' do
      verification = create(:phone_verification, phone_number: '3125552333')
      expect(described_class.new('3125552333').verification_invalid?(verification)).to eq false
    end

    it 'returns true if the verification is nil' do
      expect(described_class.new('3125552333').verification_invalid?(nil)).to eq true
    end

    it 'returns true if the verification is locked' do
      verification = create(:phone_verification, :locked, phone_number: '3125552333')
      expect(described_class.new('3125552333').verification_invalid?(verification)).to eq true
    end

    it 'returns true if the verification is expired' do
      verification = create(:phone_verification, :expired, phone_number: '3125552333')
      expect(described_class.new('3125552333').verification_invalid?(verification)).to eq true
    end
  end

  describe '#token_matches?' do
    before(:each) do
      @verification = create(:phone_verification)
    end

    it 'returns true if the verification token matches the one found via the phone number lookup' do
      expect(described_class.new(@verification.phone_number, @verification.verification_token).token_matches?(@verification)).to eq true
    end

    it 'returns false if the verification token does not match the one found via the phone number lookup' do
      expect(described_class.new(@verification.phone_number, '654321').token_matches?(@verification)).to eq false
    end
  end

  describe '#verification_error' do
    it 'returns back generic error message if the verification is nil' do
      expect(described_class.new('3125552333').verification_error(nil)[1]).to eq 'The information provided does not match. Please try again.'
    end

    it 'returns back the expired error message if the verification is expired' do
      verification = create(:phone_verification, :expired, phone_number: '3125552334')
      expect(described_class.new('3125552334').verification_error(verification)[1]).to eq 'The verification token used is expired. Please request a new one and try again.'
    end

    it 'returns back the locked error message if the verification is locked' do
      verification = create(:phone_verification, :locked, phone_number: '3125552335')
      expect(described_class.new('3125552335').verification_error(verification)[1]).to eq 'Login attempts have been locked for this phone number. Try again in 60 minutes.'
    end
  end

  describe '#append_login_attempt' do
    it 'adds the current time to the login attempts array on the verification resource' do
      verification = create(:phone_verification, phone_number: '3125551444')
      Timecop.freeze(Time.parse('2017-01-15 06:00:00 UTC')) do
        expect { described_class.new('3125552336').append_login_attempt(verification) }.to change { PhoneVerification.find_by_id(verification.id).login_attempts.count }.from(0).to(1)
        expect(PhoneVerification.find_by_id(verification.id).login_attempts.first).to eq '2017-01-15 06:00:00 UTC'
      end
    end
  end

  describe '#create_and_verify_user' do
    before(:each) do
      @verification = create(:phone_verification, :unverified)
    end

    it 'creates a new user' do
      expect { described_class.new(@verification.phone_number).create_and_verify_user(@verification) }.to change { User.count }.by(1)
    end

    it 'associated the verification to the user' do
      # Ensure no user is associated
      @verification.user_id = nil
      @verification.save!

      expect { described_class.new(@verification.phone_number).create_and_verify_user(@verification) }.to change { PhoneVerification.find_by_id(@verification).user_id }.from(nil)
    end

    it 'updates the verified_at timestamp to the current date/time' do
      Timecop.freeze(Time.parse('2017-01-15 06:00:00 UTC')) do
        expect { described_class.new(@verification.phone_number).create_and_verify_user(@verification) }.to change { PhoneVerification.find_by_id(@verification).verified_at }.from(nil).to(Time.parse('2017-01-15 06:00:00 UTC'))
      end
    end
  end

  describe '#allowable_phone_number' do
    it 'returns true if limited recipients is empty' do
      allow(SmsAuth::Engine).to receive(:limited_recipients) { [] }
      expect(described_class.new('3125552333').send(:allowable_phone_number?, '3125552333')).to eq true
    end

    it 'returns true if limited recipients has the phone_number in it' do
      allow(SmsAuth::Engine).to receive(:limited_recipients) { %w(3125552332) }
      expect(described_class.new('3125552332').send(:allowable_phone_number?, '3125552332')).to eq true
    end

    it 'returns false if limited recipients is set but does not contain the phone_number' do
      allow(SmsAuth::Engine).to receive(:limited_recipients) { %w(3125552332) }
      expect(described_class.new('3125552333').send(:allowable_phone_number?, '3125552333')).to eq false
    end
  end
end

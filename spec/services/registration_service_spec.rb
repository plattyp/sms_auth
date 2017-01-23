require 'rails_helper'

RSpec.describe RegistrationService do
  describe '#register_user' do
  end

  describe '#send_verification_token' do
  end

  describe '#verify_user' do
  end

  describe '#create_authentication_token' do
    before(:all) do
      @user = create(:user)
    end

    it 'adds an authentication_token for the given user' do
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
    before(:all) do
      @verification = create(:phone_verification, phone_number: '3125552333')
    end
    it 'returns true if the verification token matches the one found via the phone number lookup' do
      expect(described_class.new('3125552333', @verification.verification_token).token_matches?(@verification)).to eq true
    end

    it 'returns false if the verification token does not match the one found via the phone number lookup' do
      expect(described_class.new('3125552333', '654321').token_matches?(@verification)).to eq false
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
  end

  describe '#create_and_verify_user' do
  end

  describe '#allowable_phone_number' do
  end
end

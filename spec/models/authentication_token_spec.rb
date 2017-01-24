require 'rails_helper'

RSpec.describe AuthenticationToken, type: :model do
  describe '.expired_tokens' do
    before(:each) do
      @user = create(:user)
    end

    it 'returns back all tokens that have passed their expiration date' do
      # Create 4 expired tokens
      create(:authentication_token, user: @user, expired_at: Time.now.utc - 3.days)
      create(:authentication_token, user: @user, expired_at: Time.now.utc - 2.days)
      create(:authentication_token, user: @user, expired_at: Time.now.utc - 1.days)
      create(:authentication_token, user: @user, expired_at: Time.now.utc - 5.hours)

      # Create 3 unexpired tokens
      create(:authentication_token, user: @user, expired_at: Time.now.utc + 5.hours)
      create(:authentication_token, user: @user, expired_at: Time.now.utc + 3.days)
      create(:authentication_token, user: @user, expired_at: Time.now.utc + 9.days)

      expect(described_class.expired_tokens.count).to eq 4
    end

    it 'includes deleted tokens as well that were deleted before todays date' do
      # Create 2 expired tokens
      create(:authentication_token, user: @user, expired_at: Time.now.utc - 3.days)
      create(:authentication_token, user: @user, expired_at: Time.now.utc - 2.days)

      # Create 1 deleted token
      create(:authentication_token, user: @user, expired_at: nil, deleted_at: Time.now.utc - 1.days)

      # Create 3 unexpired/undeleted tokens
      create(:authentication_token, user: @user, expired_at: Time.now.utc + 5.hours)
      create(:authentication_token, user: @user, expired_at: Time.now.utc + 3.days)
      create(:authentication_token, user: @user, expired_at: Time.now.utc + 9.days)

      expect(described_class.expired_tokens.count).to eq 3
    end
  end

  describe '.find_user_by_token' do
    before(:each) do
      @user_one = create(:user)
      @user_two = create(:user)
      @token_user_one = create(:authentication_token, user: @user_one)
      @token_user_two = create(:authentication_token, user: @user_two)
    end

    it 'returns back the User associated with the token that is passed in' do
      expect(described_class.find_user_by_token(@token_user_one.body)).to eq @user_one
      expect(described_class.find_user_by_token(@token_user_two.body)).to eq @user_two
    end

    it 'returns nil if the token does not match anything' do
      expect(described_class.find_user_by_token('bs-token-123')).to eq nil
    end

    it 'returns nil if the token passed in is nil' do
      expect(described_class.find_user_by_token(nil)).to eq nil
    end
  end

  describe '#generate_token' do
    it 'sets the body of the authentication_token before saving it' do
      user = create(:user)
      auth_token = build(:authentication_token, :without_body, user: user)
      expect(auth_token.body).to eq nil
      auth_token.save
      body = AuthenticationToken.find_by_id(auth_token.id).body
      expect(body).not_to eq nil
    end
  end

  describe '#soft_delete' do
    before(:each) do
      @user = create(:user)
    end

    it 'sets the deleted_at to now' do
      Timecop.freeze(Time.parse('2017-01-15 06:00:00 UTC')) do
        auth_token = create(:authentication_token, user: @user)
        expect { auth_token.soft_delete }.to change { AuthenticationToken.find_by_id(auth_token.id).deleted_at }.from(nil).to(Time.parse('2017-01-15 06:00:00 UTC'))
      end
    end
  end

  describe '#friendly_token' do
    it 'returns back a token that is 40 characters in length' do
      auth_token = build(:authentication_token, :without_body, user: @user)
      expect(auth_token.send(:friendly_token).length).to eq 40
    end
  end

  describe '#default_expired_at' do
    it 'returns a time that is N days in the future based on the configuration' do
      Timecop.freeze(Time.parse('2017-01-15 06:00:00 UTC')) do
        auth_token = build(:authentication_token, :without_body, user: @user)
        expect(auth_token.send(:default_expired_at)).to be_kind_of Time
        expect(auth_token.send(:default_expired_at).to_date.to_s).to eq '2017-04-15'
      end
    end
  end
end

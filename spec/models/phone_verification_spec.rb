require 'rails_helper'

RSpec.describe PhoneVerification, type: :model do
  describe 'save' do
    it 'will cleanup the phone_number before saving to ensure it doesnt have spaces or dashes' do
      verification = create(:phone_verification, phone_number: '312-423-2333 ')
      expect(PhoneVerification.find_by_id(verification).phone_number).to eq '3124232333'
    end
  end

  describe '.find_by_phone_number' do
    before(:all) do
      @verification_one = create(:phone_verification, phone_number: '9012222222')
      @verification_two = create(:phone_verification, phone_number: '3122222222')
    end

    it 'returns the PhoneVerification instance based on the phone number passed in' do
      expect(described_class.find_by_phone_number('9012222222')).to eq @verification_one
    end

    it 'cleans up the number even if there are extra spaces or dashes' do
      expect(described_class.find_by_phone_number('312-222-2222 ')).to eq @verification_two
    end
  end

  describe '#reset_verification_token' do
    it 'sets the verification_token to a different number' do
      verification = create(:phone_verification, verification_token: '123456')
      expect { verification.reset_verification_token }.to change { PhoneVerification.find_by_id(verification.id).verification_token }
    end

    it 'sets the expired_at to the current time plus the config limit' do
      Timecop.freeze(Time.parse('2017-01-15 06:00:00 UTC')) do
        verification = create(:phone_verification, expired_at: nil)
        expect { verification.reset_verification_token }.to change { PhoneVerification.find_by_id(verification.id).expired_at }.from(nil).to(Time.parse('2017-01-15 06:05:00 UTC'))
      end
    end
  end

  describe '#reset_after_successful_login' do
    it 'sets the login_attempts array to empty' do
      login_attempts = ['2017-01-16 03:16:41 UTC', '2017-01-16 03:16:35 UTC', '2017-01-16 03:16:28 UTC']
      verification = create(:phone_verification, login_attempts: login_attempts)
      expect { verification.reset_after_successful_login }.to change {
        PhoneVerification.find_by_id(verification.id).login_attempts
      }.from(login_attempts).to([])
    end

    it 'sets expired_at and unlocked_at to nil' do
      verification = create(:phone_verification, expired_at: Time.zone.now.utc, unlocked_at: Time.zone.now.utc)
      expect { verification.reset_after_successful_login }.to change {
        PhoneVerification.find_by_id(verification.id).expired_at
      }.to(nil)
      expect(verification.unlocked_at).to eq nil
    end
  end

  describe '#has_user?' do
    it 'returns true if the verification_token is associated to a user' do
      user = create(:user)
      verification = create(:phone_verification, user: user)
      expect(verification.has_user?).to eq true
    end

    it 'returns false if the verification_token is not associated with a user' do
      verification = create(:phone_verification, user: nil)
      expect(verification.has_user?).to eq false
    end
  end

  describe '#locked?' do
    it 'returns true if unlocked_at is set and the current time is behind unlocked_at' do
      verification = create(:phone_verification, unlocked_at: Time.zone.now.utc + 1.hour)
      expect(verification.locked?).to eq true
    end

    it 'returns false if unlocked_at is nil' do
      verification = create(:phone_verification, unlocked_at: nil)
      expect(verification.locked?).to eq false
    end

    it 'returns false if unlocked_at is behind the current time' do
      verification = create(:phone_verification, unlocked_at: Time.zone.now.utc - 1.minute)
      expect(verification.locked?).to eq false
    end
  end

  describe '#expired?' do
    it 'returns true if expired_at is set and the current time is ahead of expired_at' do
      verification = create(:phone_verification, expired_at: Time.zone.now.utc - 5.minutes)
      expect(verification.expired?).to eq true
    end

    it 'returns false if expired_at is nil' do
      verification = create(:phone_verification, expired_at: nil)
      expect(verification.expired?).to eq false
    end

    it 'returns false if expired_at is ahead of the current time' do
      verification = create(:phone_verification, expired_at: Time.zone.now.utc + 5.minutes)
      expect(verification.expired?).to eq false
    end
  end

  describe '#lock_account' do
    it 'sets the unlocked_at to be the current time plus the time set in the config' do
      Timecop.freeze(Time.parse('2017-01-15 06:00:00 UTC')) do
        verification = create(:phone_verification)
        expect { verification.lock_account }.to change { PhoneVerification.find_by_id(verification.id).unlocked_at }.from(nil).to(Time.parse('2017-01-15 07:00:00 UTC'))
      end
    end
  end

  describe '#above_maximum_attempts?' do
    it 'returns true if the number of login attempts is equal to or greater the maximum set by the config' do
      Timecop.freeze(Time.parse('2017-01-16 03:20:00 UTC')) do
        login_attempts = ['2017-01-16 03:16:41 UTC', '2017-01-16 03:16:35 UTC', '2017-01-16 03:16:28 UTC']
        verification = create(:phone_verification, login_attempts: login_attempts)
        expect(verification.above_maximum_attempts?).to eq true
      end
    end

    it 'returns false if the number of login attempts within the last N minutes is less than the maximum set by the config' do
      Timecop.freeze(Time.parse('2017-01-16 03:20:00 UTC')) do
        login_attempts = ['2017-01-16 03:16:41 UTC', '2017-01-16 03:14:35 UTC', '2017-01-16 01:11:28 UTC']
        verification = create(:phone_verification, login_attempts: login_attempts)
        expect(verification.above_maximum_attempts?).to eq false
      end
    end

    it 'returns false if the number of login attempts is less than the maximum set by the config' do
      Timecop.freeze(Time.parse('2017-01-16 03:20:00 UTC')) do
        login_attempts = ['2017-01-16 03:16:41 UTC', '2017-01-16 03:16:35 UTC']
        verification = create(:phone_verification, login_attempts: login_attempts)
        expect(verification.above_maximum_attempts?).to eq false
      end
    end
  end

  describe '#unlocks_in_minutes' do
    it 'returns the number of minutes until the status of the phone verification is no longer locked' do
      Timecop.freeze(Time.parse('2017-01-15 06:00:00 UTC')) do
        verification = create(:phone_verification, unlocked_at: Time.parse('2017-01-15 06:45:00 UTC'))
        expect(verification.unlocks_in_minutes).to eq 45
      end
    end
  end
end

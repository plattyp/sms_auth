class PhoneVerification < ActiveRecord::Base
  belongs_to :user

  before_save :cleanup_phone_number
  before_create :generate_verification_token

  def self.find_by_phone_number(phone_num)
    where('phone_number = ?', PhoneNumberUtils.cleanup_phone_number(phone_num)).first
  end

  def reset_verification_token
    generate_verification_token
    self.expired_at = (Time.zone.now.utc + SmsAuth::Engine.verification_token_time_limit_minutes.minutes)
    save!
  end

  def reset_after_successful_login
    self.login_attempts = []
    self.expired_at = nil
    self.unlocked_at = nil
    save!
  end

  def has_user?
    !user.nil?
  end

  def locked?
    !unlocks_in_minutes.nil?
  end

  def expired?
    return false if expired_at.nil?
    Time.zone.now.utc >= expired_at
  end

  def lock_account
    self.unlocked_at = (Time.zone.now.utc + SmsAuth::Engine.lock_min_duration.minutes)
    save!
  end

  def above_maximum_attempts?
    login_attempts.select { |attempt| attempt > (Time.now.utc - SmsAuth::Engine.max_login_attempt_within_minutes.minutes) }.count >= SmsAuth::Engine.max_login_attempts
  end

  def unlocks_in_minutes
    return nil if unlocked_at.nil? || Time.zone.now.utc >= unlocked_at
    ((unlocked_at - Time.zone.now.utc) / 60).round
  end

  def generate_verification_token
    self.verification_token = rand(100_000..999_999)
  end

  private

  def cleanup_phone_number
    self.phone_number = PhoneNumberUtils.cleanup_phone_number(phone_number)
  end
end

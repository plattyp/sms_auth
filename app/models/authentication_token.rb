class AuthenticationToken < ActiveRecord::Base
  belongs_to :user

  before_create :generate_token!

  def self.expired_tokens
    where('expired_at <= ? OR deleted_at <= ?', Time.zone.now.utc, Time.zone.now.utc)
  end

  def self.find_by_body(auth_token)
    where(body: auth_token).first
  end

  def self.find_user_by_token(auth_token)
    return nil if auth_token.nil?
    User.find_by_id(find_user_id_by_token(auth_token))
  end

  def generate_token!
    self.body = friendly_token if body.nil?
    self.expired_at = default_expired_at if expired_at.nil?
  end

  def soft_delete
    self.deleted_at = Time.zone.now.utc
    save!
  end

  private

  def self.find_user_id_by_token(auth_token)
    result = where(body: auth_token)
             .where('deleted_at IS NULL')
             .where('expired_at > ?', Time.now.utc)
             .select(:user_id)
             .first

    return result.user_id unless result.nil?
    nil
  end

  def friendly_token
    SecureRandom.urlsafe_base64((40 * 3) / 4).tr('lIO0', 'sxyz')
  end

  def default_expired_at
    Time.zone.now + SmsAuth::Engine.default_token_expiration_days.days
  end
end

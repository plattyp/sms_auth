class RegistrationService
  attr_reader :phone_number, :verification_token

  def initialize(phone_number, verification_token = nil)
    @phone_number = PhoneNumberUtils.cleanup_phone_number(phone_number)
    @verification_token = verification_token
  end

  def register_user
    unless valid_phone_number?(phone_number)
      return [false, 'The phone number provided is not valid']
    end

    unless allowable_phone_number?(phone_number)
      return [false, 'The phone number provided is not allowed to be interacted']
    end

    verification = PhoneVerification.find_by_phone_number(phone_number)
    if verification.nil?
      verification = PhoneVerification.create(phone_number: phone_number)
      send_verification_token(verification)
      return [true, '']
    end

    return [false, "Login attempts have been locked for this phone number. Try again in #{verification.unlocks_in_minutes} minutes."] if verification.locked?

    send_verification_token(verification)
    [true, '']
  end

  def send_verification_token(phone_verification)
    phone_verification.reset_verification_token
    send_out_message_synchronously(phone_number, "Your verification code is #{phone_verification.verification_token}")
  end

  def verify_user
    verification = PhoneVerification.find_by_phone_number(phone_number)
    if verification_invalid?(verification)
      return verification_error(verification)
    end

    # Determine if this is the correct token
    # If it is not then log the attempt
    unless token_matches?(verification)
      append_login_attempt(verification)
      if verification.above_maximum_attempts?
        verification.lock_account
        return [false, 'This phone number has been temporarily locked due to unsuccessful login attempts. Please try again in a few minutes.']
      end
      return [false, 'The verification token provided does not match', nil, nil, false]
    end

    # If a user doesnt exist, create one, associate it with the verification, and set verified_at
    user = create_and_verify_user(verification) unless verification.has_user?

    token = create_authentication_token(verification.user_id || user.id)
    verification.reset_verification_token

    [true, '', token.user_id, token.body, !user.nil?]
  end

  def create_authentication_token(user_id)
    AuthenticationToken.create(user_id: user_id)
  end

  def verification_invalid?(verification)
    verification.nil? || verification.locked? || verification.expired?
  end

  def token_matches?(verification)
    verification.verification_token == verification_token
  end

  def verification_error(verification)
    if verification.nil?
      return verification_error_response('The information provided does not match. Please try again.')
    end

    if verification.locked?
      return verification_error_response("Login attempts have been locked for this phone number. Try again in #{verification.unlocks_in_minutes} minutes.")
    end

    if verification.expired?
      return verification_error_response('The verification token used is expired. Please request a new one and try again.')
    end

    verification_error_response('The information provided does not match. Please try again.')
  end

  def append_login_attempt(verification)
    verification.login_attempts.push(Time.zone.now.utc)
    verification.save!
  end

  def create_and_verify_user(verification)
    user = User.create
    verification.user_id = user.id
    verification.verified_at = Time.zone.now.utc
    verification.save!
    user
  end

  private

  def valid_phone_number?(phone_num)
    !phone_num.nil? && phone_num.gsub(/\D/, '').length == 10
  end

  def allowable_phone_number?(phone_num)
    SmsAuth::Engine.limited_recipients.empty? || SmsAuth::Engine.limited_recipients.include?(phone_num)
  end

  def send_out_message_synchronously(phone_num, message)
    TextMessageService.new(phone_num, message).send
  end

  def verification_error_response(error_message)
    [false, error_message, nil, nil, false]
  end
end

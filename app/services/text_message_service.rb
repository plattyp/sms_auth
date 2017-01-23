require 'twilio-ruby'

class TextMessageService
  attr_reader :phone_number, :message

  def initialize(phone_number, message)
    @phone_number = phone_number
    @message = message
  end

  def send
    return false if recipient_trap? && !allowed_recipient?
    twilio_client.account.messages.create(
      from: from_phone_number,
      to: phone_number,
      body: formatted_message
    )
  end

  def formatted_message
    has_prefix? ? "#{prefix}: #{message}" : message
  end

  def has_prefix?
    !prefix.nil?
  end

  def from_phone_number
    SmsAuth::Engine.twilio_from_number
  end

  def prefix
    SmsAuth::Engine.message_prefix
  end

  def recipient_trap?
    SmsAuth::Engine.limited_recipients.count > 0
  end

  def allowed_recipient?
    !SmsAuth::Engine.limited_recipients.index(phone_number).nil?
  end

  def twilio_client
    @twilio_client ||= Twilio::REST::Client.new
  end
end

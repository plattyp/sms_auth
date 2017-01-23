require 'rails_helper'

RSpec.describe TextMessageService do
  describe '#send' do
    before(:each) do
      @twilio_double = double('Twilio::REST::Client')
      @account_double = double('Twilio::REST::Account')
      @messages_double = double('Twilio::Rest::Messages')
    end
    it 'returns false and does not send the message if there is a recipient trap set up with config and the number is not allowed' do
      allow(SmsAuth::Engine).to receive(:limited_recipients) { %w(3124442333 3125552333) }
      service = described_class.new('3125552222', 'this is my message')
      allow(service).to receive(:twilio_client) { @twilio_double }
      expect(@twilio_double).to receive(:account).exactly(0).times
      expect(service.send).to eq false
    end

    it 'sends a message to twilio if there is a recipient trap but the number is allowed' do
      allow(SmsAuth::Engine).to receive(:limited_recipients) { %w(3125552222) }
      service = described_class.new('3125552222', 'this is my message')
      allow(service).to receive(:twilio_client) { @twilio_double }
      expect(@twilio_double).to receive(:account) { @account_double }.exactly(1).times
      expect(@account_double).to receive(:messages) { @messages_double }.exactly(1).times
      expect(@messages_double).to receive(:create).exactly(1).times
      service.send
    end

    it 'sends a message to twilio if there is no recipient trap' do
      service = described_class.new('3125552222', 'this is my message')
      allow(service).to receive(:twilio_client) { @twilio_double }
      expect(@twilio_double).to receive(:account) { @account_double }.exactly(1).times
      expect(@account_double).to receive(:messages) { @messages_double }.exactly(1).times
      expect(@messages_double).to receive(:create).exactly(1).times
      service.send
    end
  end
  describe '#formatted_message' do
    it 'returns back the message if no prefix is set in the config' do
      service = described_class.new('3125552333', 'this is my message')
      expect(service.formatted_message).to eq 'this is my message'
    end

    it 'returns back a prefixed message if prefix is set in the config' do
      service = described_class.new('3125552333', 'this is my message')
      allow(service).to receive(:prefix) { 'Prefix' }
      expect(service.formatted_message).to eq 'Prefix: this is my message'
    end
  end

  describe '#has_prefix?' do
    it 'returns true if prefix is set in the config' do
      service = described_class.new('3125552333', 'this is my message')
      allow(service).to receive(:prefix) { 'Prefix' }
      expect(service.has_prefix?).to eq true
    end

    it 'returns false if prefix is not set in the config' do
      service = described_class.new('3125552333', 'this is my message')
      expect(service.has_prefix?).to eq false
    end
  end

  describe '#from_phone_number' do
    it 'returns the phone number set in the config' do
      allow(SmsAuth::Engine).to receive(:twilio_from_number) { '3125552333' }
      expect(described_class.new('3125552333', 'this is my message').from_phone_number).to eq '3125552333'
    end
  end

  describe '#prefix' do
    it 'returns the prefix set in the config' do
      allow(SmsAuth::Engine).to receive(:message_prefix) { 'Prefix' }
      expect(described_class.new('3125552333', 'this is my message').prefix).to eq 'Prefix'
    end
  end

  describe '#recipient_trap?' do
    it 'returns true if the array limited_recipients is set on config' do
      allow(SmsAuth::Engine).to receive(:limited_recipients) { %w(3124442333 3125552333) }
      expect(described_class.new('3125552333', 'this is my message').recipient_trap?).to eq true
    end

    it 'returns false if the array limited_recipients is empty on config' do
      expect(described_class.new('3125552333', 'this is my message').recipient_trap?).to eq false
    end
  end

  describe '#allowed_recipient?' do
    it 'returns true if the array limited_recipients on the config contains the phone_number' do
      allow(SmsAuth::Engine).to receive(:limited_recipients) { %w(3124442333 3125552333) }
      expect(described_class.new('3125552333', 'this is my message').allowed_recipient?).to eq true
    end

    it 'returns false if the array limited_recipients on the config does not contain the phone_number' do
      allow(SmsAuth::Engine).to receive(:limited_recipients) { %w(3124442333 3125552333) }
      expect(described_class.new('3125552335', 'this is my message').allowed_recipient?).to eq false
    end
  end
end

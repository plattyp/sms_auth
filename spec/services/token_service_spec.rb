require 'rails_helper'

RSpec.describe TokenService do
  describe '#logout' do
    before(:each) do
      @auth_token = create(:authentication_token, body: 'mHs8Yj3nnkYUdDyXDaPBawHNzQzET5qNDTzJ2krs')
    end

    it 'returns true if it was able to find and soft delete the token' do
      expect(described_class.new(@auth_token.body).logout[0]).to eq true
    end

    it 'soft deletes the authentication token if it is able to find it' do
      Timecop.freeze(Time.parse('2017-01-15 06:00:00 UTC')) do
        expect { described_class.new(@auth_token.body).logout }.to change { AuthenticationToken.find_by_id(@auth_token.id).deleted_at }.from(nil).to(Time.parse('2017-01-15 06:00:00 UTC'))
      end
    end

    it 'returns false if it was not able to find the token' do
      expect(described_class.new('121424124124124124').logout[0]).to eq false
    end
  end
end

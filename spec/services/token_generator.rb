require 'rails_helper'

RSpec.describe TokenGenerator do
  describe 'class methods' do
    let(:access_token) { described_class.access_token({ user_id: '1' }) }
    context 'access_token' do
      it 'return an access token' do
        expect(access_token).to_not eq nil
      end
    end

    context 'verify' do
      let(:payload) { described_class.verify(access_token) }
      it 'return payload hash' do
        expect(payload['user_id']).to eq('1')
      end
    end

    context 'refresh_token' do
      it 'return an refresh token' do
        expect(described_class.refresh_token).to_not eq nil
      end
    end
  end
end

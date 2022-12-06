require 'rails_helper'

RSpec.describe TokenGenerator do
  describe 'methods' do
    context 'access_token' do
      it 'return an access token' do
        access_token = TokenGenerator.access_token({ user_id: '1' })
        expect(access_token).to_not eq nil
      end
    end

    context 'verify' do
      it 'return payload hash' do
        access_token = TokenGenerator.access_token({ user_id: '1' })
        payload = TokenGenerator.verify(access_token)
        expect(payload['user_id']).to eq('1')
      end
    end

    context 'refresh_token' do
      it 'return payload hash' do
        refresh_token = TokenGenerator.refresh_token
        expect(refresh_token).to_not eq nil
      end
    end
  end
end

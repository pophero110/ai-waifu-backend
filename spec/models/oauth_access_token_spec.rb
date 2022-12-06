require 'rails_helper'

RSpec.describe OauthAccessToken, type: :model do
  describe 'attributes' do
    context 'user is not assigned' do
      it 'is not valid' do
        oauthToken =
          OauthAccessToken.new(
            token: '123',
            refresh_token: '123',
            expired_at: Time.current,
            created_at: Time.current,
          )
        expect(oauthToken.valid?).to eq false
        expect(oauthToken.errors.messages[:user][0]).to eq 'must exist'
      end
    end
  end
  describe 'instance methods' do
    context 'expired?' do
      it 'return true' do
        oauthToken =
          OauthAccessToken.create(
            token: '123',
            refresh_token: '123',
            expired_at: Time.current - 1.day,
            created_at: Time.current,
          )
        expect(oauthToken.expired?).to eq true
      end
    end
  end
end

require 'rails_helper'

RSpec.describe Authenticator do
  describe 'methods' do
    context 'sign_in' do
      it 'saves token into database' do
        user = create(:user)

        Authenticator.sign_in(user)

        expect(user.oauth_access_token).to_not eq(nil)
      end

      it 'return existing token' do
        user = create(:user)
        oldToken =
          OauthAccessToken.create!(
            token: TokenGenerator.access_token({ user_id: user.id }),
            refresh_token: TokenGenerator.refresh_token,
            expired_at: 24.hours.from_now,
            user: user
          )

        token = Authenticator.sign_in(user)

        expect(oldToken.token).to eq token.token
        expect(oldToken.refresh_token).to eq token.refresh_token
      end
    end

    context 'sign_out successfully' do
      it 'destroy token in database' do
        user = create(:user)
        Authenticator.sign_in(user)
        access_token = user.reload.oauth_access_token.token

        expect { Authenticator.sign_out(access_token) }.to change {
          OauthAccessToken.count
        }.from(1).to(0)

        expect(user.reload.oauth_access_token).to eq nil
      end
      it 'return true' do
        user = create(:user)
        Authenticator.sign_in(user)
        access_token = user.reload.oauth_access_token.token

        expect(Authenticator.sign_out(access_token)).to eq true
      end
    end

    context 'sign_out unsuccessfully' do
      it 'return false' do
        user = create(:user)
        exp = Time.current - 1.day
        Authenticator.sign_in(user, exp)
        access_token = user.reload.oauth_access_token.token

        expect(Authenticator.sign_out(access_token)).to eq false
      end
    end

    context 'refresh_token' do
      it 'update tokens in database' do
        user = create(:user)
        oldToken = Authenticator.sign_in(user)
        access_token = oldToken.token
        refresh_token = oldToken.refresh_token

        newToken = Authenticator.refresh_token(user)

        expect(access_token).to_not eq newToken.token
        expect(refresh_token).to_not eq newToken.refresh_token
      end
    end
  end
end

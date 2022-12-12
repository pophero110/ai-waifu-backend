require 'rails_helper'

RSpec.describe Authenticator do
  describe 'methods' do
    let(:user) { create(:user) }
    context 'sign_in' do
      it 'saves token into database' do
        Authenticator.sign_in(user)

        expect(user.oauth_access_token).to_not eq(nil)
      end

      it 'return existing token' do
        oldToken = create(:oauth_access_token, user: user)

        token = Authenticator.sign_in(user)

        expect(OauthAccessToken.count).to eq 1
        expect(oldToken.token).to eq token.token
        expect(oldToken.refresh_token).to eq token.refresh_token
      end
    end

    context 'sign_out' do
      let(:access_token) { user.oauth_access_token.token }
      before(:each) { Authenticator.sign_in(user) }
      context 'successfully' do
        it 'destroys token in database' do
          expect { Authenticator.sign_out(access_token) }.to change {
            OauthAccessToken.count
          }.from(1).to(0)

          expect(user.reload.oauth_access_token).to eq nil
        end
        it 'returns true' do
          expect(Authenticator.sign_out(access_token)).to eq true
        end
      end
      context 'unsuccessfully' do
        it 'return false' do
          travel_to 25.hours.from_now

          expect(Authenticator.sign_out(access_token)).to eq false
        end
      end
    end

    context 'refresh_token' do
      let(:access_token) { user.oauth_access_token.token }
      let(:refresh_token) { user.oauth_access_token.refresh_token }
      before(:each) { Authenticator.sign_in(user) }
      it 'update tokens in database' do
        travel_to 1.hour.from_now
        newToken = Authenticator.refresh_token(refresh_token)

        expect(access_token).to_not eq newToken.token
        expect(refresh_token).to_not eq newToken.refresh_token
      end
    end
  end
end

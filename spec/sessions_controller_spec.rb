require 'rails_helper'

RSpec.describe SessionsController, type: :request do
  describe 'sign_in' do
    context 'wrong email' do
      it 'return 422 with error message' do
        post sign_in_path,
             params: {
               user: {
                 email: 'test@gmail.com',
                 password: 'test'
               }
             }
        expect(response).to have_http_status(422)
        expect(JSON.parse(response.body)['errors']).to eq(
          'Incorrect email or password'
        )
      end
    end
    context 'wrong password' do
      let!(:user) { User.create(email: 'test@gmail.com', password: 'test') }
      it 'return 422 with error message' do
        post sign_in_path,
             params: {
               user: {
                 email: 'test@gmail.com',
                 password: '123'
               }
             }
        expect(response).to have_http_status(422)
        expect(JSON.parse(response.body)['errors']).to eq(
          'Incorrect email or password'
        )
      end
    end

    context 'correct email and password' do
      let!(:user) { User.create(email: 'test@gmail.com', password: 'test') }
      context 'email is not cofirmed' do
        it 'return 422 with a reason' do
          post sign_in_path,
               params: {
                 user: {
                   email: 'test@gmail.com',
                   password: 'test'
                 }
               }

          expect(response).to have_http_status(401)
          body = JSON.parse(response.body)
          expect(body['errors']).to eq('Email is not confirmed')
        end
      end
      context 'email is confirmed' do
        it 'return 201 with oauth token' do
          user.update(confirmed_at: Time.current)

          post sign_in_path,
               params: {
                 user: {
                   email: 'test@gmail.com',
                   password: 'test'
                 }
               }

          expect(response).to have_http_status(201)
          body = JSON.parse(response.body)
          expect(body['access_token']).to eq(user.oauth_access_token.token)
          expect(body['refresh_token']).to eq(
            user.oauth_access_token.refresh_token
          )
        end
      end
    end

    context 'already login' do
      let!(:user) do
        User.create(
          email: 'test@gmail.com',
          password: 'test',
          confirmed_at: Time.current
        )
      end
      before(:each) do
        post sign_in_path,
             params: {
               user: {
                 email: 'test@gmail.com',
                 password: 'test'
               }
             }
      end
      it 'return 201 with previous oauth token' do
        post sign_in_path,
             params: {
               user: {
                 email: 'test@gmail.com',
                 password: 'test'
               }
             }

        expect(OauthAccessToken.count).to eq(1)
        expect(response).to have_http_status(201)
        body = JSON.parse(response.body)
        expect(body['access_token']).to eq(user.oauth_access_token.token)
        expect(body['refresh_token']).to eq(
          user.oauth_access_token.refresh_token
        )
      end
    end
  end

  describe 'sign_out' do
    let!(:user) do
      User.create(
        email: 'test@gmail.com',
        password: 'test',
        confirmed_at: Time.current
      )
    end
    before(:each) do
      post sign_in_path,
           params: {
             user: {
               email: user.email,
               password: 'test'
             }
           }
    end
    context 'with correct token' do
      it 'return 200' do
        delete sign_out_path,
               headers: {
                 'Authorization' => "Bearer #{user.oauth_access_token.token}"
               }

        expect(response).to have_http_status(200)
        expect(user.reload.oauth_access_token.present?).to eq(false)
      end
    end

    context 'with wrong token' do
      it 'return 200' do
        delete sign_out_path,
               headers: {
                 'Authorization' =>
                   'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c'
               }

        expect(response).to have_http_status(401)
        expect(JSON.parse(response.body)['errors']).to eq 'Invalid Token'
      end
    end

    context 'with expired token' do
      let!(:user_2) do
        User.create(
          email: 'test1@gmail.com',
          password: 'test1',
          confirmed_at: Time.current
        )
      end

      it 'return 200' do
        post sign_in_path,
             params: {
               user: {
                 email: user_2.email,
                 password: 'test1'
               }
             }

        travel_to (25.hours.from_now)
        delete sign_out_path,
               headers: {
                 'Authorization' => "Bearer #{user_2.oauth_access_token.token}"
               }

        expect(response).to have_http_status(401)
        expect(JSON.parse(response.body)['errors']).to eq 'Invalid Token'
      end
    end
  end

  describe 'refresh_token' do
    context 'with correct refresh_token' do
      let!(:user) do
        User.create(
          email: 'test@gmail.com',
          password: 'test',
          confirmed_at: Time.current
        )
      end
      let(:action) do
        -> {
          put refresh_token_path,
              params: {
                refresh_token: user.oauth_access_token.refresh_token
              }
        }
      end
      before(:each) do
        post sign_in_path,
             params: {
               user: {
                 email: user.email,
                 password: 'test'
               }
             }
      end
      it 'returns 200' do
        action.call

        expect(response).to have_http_status(200)
      end

      it 'returns token' do
        action.call

        oauthToken = user.oauth_access_token.reload
        body = JSON.parse(response.body)
        expect(body['access_token']).to eq oauthToken.token
        expect(body['refresh_token']).to eq oauthToken.refresh_token
      end
    end

    context 'with wrong refresh token' do
      let(:action) do
        -> {
          put refresh_token_path,
              params: {
                refresh_token:
                  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c'
              }
        }
      end
      it 'returns 401 with errors' do
        action.call

        expect(response).to have_http_status(401)
        expect(JSON.parse(response.body)['errors']).to eq 'Invalid Token'
      end
    end

    context 'with expired refresh token' do
      let!(:user) do
        User.create(
          email: 'test@gmail.com',
          password: 'test',
          confirmed_at: Time.current
        )
      end
      let(:action) do
        -> {
          put refresh_token_path,
              params: {
                refresh_token: user.oauth_access_token.refresh_token
              }
        }
      end
      before(:each) do
        post sign_in_path,
             params: {
               user: {
                 email: user.email,
                 password: 'test'
               }
             }
      end
      it 'returns 401 with errors' do
        travel_to 25.hours.from_now

        action.call

        expect(response).to have_http_status(401)
        expect(JSON.parse(response.body)['errors']).to eq 'Expired Token'
      end
      it 'deletes expired token in database' do
        travel_to 25.hours.from_now

        expect { action.call }.to change { OauthAccessToken.count }.from(1).to(
          0
        )

        expect(user.reload.oauth_access_token).to eq nil
      end
    end
  end
end

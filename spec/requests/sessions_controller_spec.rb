require 'rails_helper'

RSpec.describe Api::SessionsController, type: :request do
  include_context 'authenticated request'
  describe 'POST sign_in' do
    let(:action) { -> { post sign_in_api_sessions_path, params: params } }
    let(:password) { 'test' }
    let(:email) { 'test@gmail.com' }
    let(:user) { create(:user, email: email, password: password) }
    let(:params) { { user: { email: email, password: password } } }
    context 'wrong email' do
      let(:email) { 'wrong@gmail.com' }
      it 'return 400 with error message' do
        action.call
        expect(response).to have_http_status(422)
        expect(JSON.parse(response.body)['errors']).to eq(
          'Incorrect email or password'
        )
      end
    end
    context 'wrong password' do
      let(:password) { 'wrong' }
      it 'return 400 with error message' do
        action.call
        expect(response).to have_http_status(422)
        expect(JSON.parse(response.body)['errors']).to eq(
          'Incorrect email or password'
        )
      end
    end

    context 'correct email and password' do
      context 'email is not cofirmed' do
        before(:each) { user.update(confirmed_at: nil) }
        it 'return 422' do
          action.call

          expect(response).to have_http_status(422)
          body = JSON.parse(response.body)
          expect(body['errors']).to eq('Email is not confirmed')
        end
      end
      context 'email is confirmed' do
        before(:each) { user.update(confirmed_at: Time.current) }
        it 'return 201 with oauth token' do
          action.call

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
      let!(:user) { create(:user) }
      before(:each) { action.call }
      it 'return 201 with previous oauth token' do
        action.call

        expect(response).to have_http_status(201)
        body = JSON.parse(response.body)
        expect(body['access_token']).to eq(user.oauth_access_token.token)
        expect(body['refresh_token']).to eq(
          user.oauth_access_token.refresh_token
        )
      end
    end
  end

  describe 'DELETE sign_out' do
    let(:password) { 'test' }
    let(:user) { create(:user, password: password) }
    let(:token) { user.oauth_access_token }
    let(:action) do
      -> {
        send_request(
          action: :delete,
          path: sign_out_api_sessions_path,
          token: token,
          resource_owner: user
        )
      }
    end
    before(:each) do
      post sign_in_api_sessions_path,
           params: {
             user: {
               email: user.email,
               password: password
             }
           }
    end
    let(:params) { nil }
    context 'with correct token' do
      it 'return 200' do
        action.call

        expect(response).to have_http_status(200)
        expect(user.reload.oauth_access_token.present?).to eq(false)
      end
    end

    context 'with wrong token' do
      let(:token) { OpenStruct.new({ token: 'fake_token' }) }
      it 'return 200' do
        action.call

        expect(response).to have_http_status(422)
        expect(JSON.parse(response.body)['errors']).to eq 'Invalid Token'
      end
    end

    context 'with expired token' do
      it 'return 200' do
        travel_to (25.hours.from_now)
        action.call

        expect(response).to have_http_status(422)
        expect(JSON.parse(response.body)['errors']).to eq 'Invalid Token'
      end
    end
  end

  describe 'put refresh_token' do
    let(:password) { 'test' }
    let(:user) { create(:user, password: password) }
    let(:oauth_token) { user.oauth_access_token }
    let(:refresh_token) { oauth_token.refresh_token }
    let(:action) do
      -> {
        put refresh_token_api_sessions_path,
            params: {
              refresh_token: refresh_token
            }
      }
    end
    before(:each) do
      post sign_in_api_sessions_path,
           params: {
             user: {
               email: user.email,
               password: password
             }
           }
    end
    context 'with correct refresh_token' do
      it 'returns 200' do
        action.call

        expect(response).to have_http_status(200)
      end

      it 'returns new token' do
        action.call

        body = JSON.parse(response.body)
        expect(body['access_token']).to_not eq oauth_token.token
        expect(body['refresh_token']).to_not eq oauth_token.refresh_token
      end
    end

    context 'with wrong refresh token' do
      let(:refresh_token) { 'fake_token' }
      it 'returns 400 with errors' do
        action.call

        expect(response).to have_http_status(422)
        expect(JSON.parse(response.body)['errors']).to eq 'Invalid Token'
      end
    end

    context 'with expired refresh token' do
      it 'returns 400 with errors' do
        travel_to 25.hours.from_now

        action.call

        expect(response).to have_http_status(422)
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

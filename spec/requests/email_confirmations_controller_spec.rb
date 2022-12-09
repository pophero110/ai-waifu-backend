require 'rails_helper'

RSpec.describe Api::EmailConfirmationsController, type: :request do
  include_context 'authenticated request'
  describe 'GET verify' do
    let!(:user) { create(:user, confirmed_at: nil) }
    let(:confirmation_token) { user.generate_confirmation_token }
    let(:action) do
      -> {
        get verify_api_email_confirmations_path(
              confirmation_token: confirmation_token
            )
      }
    end
    context 'Valid confirmation token' do
      context 'Email is unconfirmed' do
        it 'calls confirmes_email?' do
          expect_any_instance_of(User).to receive(:confirms_email?)
          action.call
        end
        it 'redirects user to web client login page' do
          action.call

          expect(response).to have_http_status(302)
          expect(response).to redirect_to(web_client_login_path(status: '200'))
        end
      end

      context 'email is confirmed' do
        before { user.update(confirmed_at: Time.current) }
        it 'redirects user to web client login page' do
          action.call

          expect(response).to have_http_status(302)
          expect(response).to redirect_to(
            web_client_login_path(
              status: '422',
              errors: 'Your email address has been confirmed'
            )
          )
        end
      end
    end

    context 'invalid confirmation Token' do
      let(:confirmation_token) { 'fake_token' }
      it 'redirects user to web client email confirmation page' do
        action.call

        expect(response).to have_http_status(302)
        expect(response).to redirect_to(
          web_client_email_confirmation_path(
            status: '422',
            errors: 'Invalid Confirmation Token'
          )
        )
      end
    end
  end

  describe 'post send_email_confirmation' do
    let(:user) { create(:user) }
    let(:action) { -> { post api_email_confirmations_path, params: params } }
    let(:params) { { user: { email: user.email } } }
    context 'email is found' do
      it 'calls send_confirmation_email!' do
        expect_any_instance_of(User).to receive(:send_confirmation_email!)
        action.call
      end
      it 'return 200' do
        action.call
        expect(response).to have_http_status(200)
      end

      context 'email is confirmed' do
        before(:each) { user.update(confirmed_at: Time.current) }
        it 'return error' do
          action.call
          expect(response).to have_http_status(422)
          expect(
            JSON.parse(response.body)['errors']
          ).to eq 'Something went wrong'
        end
        it 'calls Rails.logger.warn' do
          expect(Rails.logger).to receive(:warn)
          action.call
        end
      end
    end
    context 'email is not found' do
      let(:params) { { user: { email: 'fake@email.co ' } } }
      it 'return error' do
        action.call
        expect(response).to have_http_status(422)
        expect(JSON.parse(response.body)['errors']).to eq 'Something went wrong'
      end
      it 'calls Rails.logger.warn' do
        expect(Rails.logger).to receive(:warn)
        action.call
      end
    end
  end
end

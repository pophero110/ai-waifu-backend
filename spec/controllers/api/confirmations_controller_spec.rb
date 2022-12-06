require 'rails_helper'

RSpec.describe Api::ConfirmationsController, type: :request do
  describe 'email confirmation' do
    context 'user is found' do
      let!(:user) { create(:user) }
      context 'email is unconfirmed' do
        it 'updates user confirmed_at attribute' do
          confirmation_token = user.generate_confirmation_token

          get api_confirm_email_path(confirmation_token: confirmation_token)

          expect(user.reload.confirmed_at).to_not eq(nil)
        end
        it 'redirects user to web client login page' do
          confirmation_token = user.generate_confirmation_token

          put api_confirm_email_path(confirmation_token: confirmation_token)

          expect(response).to have_http_status(302)
          expect(response).to redirect_to(web_client_login_path(status: '200'))
        end
      end
      context 'email is confirmed' do
        it 'redirects user to web client login page' do
          confirmation_token = user.generate_confirmation_token
          user.update(confirmed_at: Time.current)

          get api_confirm_email_path(confirmation_token: confirmation_token)

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

    context 'user is not found' do
      it 'redirects user to web client email confirmation page' do
        get api_confirm_email_path(confirmation_token: 'fake_token')

        expect(response).to have_http_status(302)
        expect(response).to redirect_to(
          web_client_email_confirmation_path(
            status: '400',
            errors: 'Invalid Confirmation Token'
          )
        )
      end
    end
  end
end

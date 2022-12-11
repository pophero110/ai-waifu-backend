require 'rails_helper'

RSpec.describe Api::PasswordResetsController, type: :request do
  include_context 'authenticated request'
  describe 'POST create' do
    let(:user) { create(:user) }
    let(:email) { { email: user.email } }
    let(:action) do
      -> {
        send_request(
          path: api_password_resets_path,
          action: :post,
          resource_owner: user
        )
      }
    end
    let(:params) { { email: email } }
    context 'email is not found' do
      it 'return 422 with errors' do
        action.call

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end

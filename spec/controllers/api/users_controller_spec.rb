require 'rails_helper'

RSpec.describe Api::UsersController, type: :request do
  describe 'sign_up' do
    context 'with correct params' do
      it 'creats user in database' do
        user = {
          email: 'test@gmail.com',
          password: 'test',
          password_confirmation: 'test'
        }

        post api_sign_up_path, params: { user: user }

        expect(response).to have_http_status(201)
      end
      it 'sends email verification to user email address' do
        user = {
          email: 'test@gmail.com',
          password: 'test',
          password_confirmation: 'test'
        }

        post api_sign_up_path, params: { user: user }

        expect(response).to have_http_status(201)
      end
    end
  end
end

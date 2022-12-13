require 'rails_helper'

RSpec.describe Api::UsersController, type: :request do
  describe 'create' do
    let(:email) { 'test@gmail.com' }
    let(:password) { 'test' }
    let(:password_confirmation) { 'test' }
    let(:action) { -> { post sign_up_api_users_path, params: params } }
    let(:params) do
      {
        email: email,
        password: password,
        password_confirmation: password_confirmation
      }
    end
    context 'with valid params' do
      it 'creates user in database' do
        expect { action.call }.to change { User.count }.by(1)
      end
      it 'calls EmailSender.email_confirmation' do
        expect(EmailSender).to receive(:email_confirmation).with(
          instance_of(User)
        )
        action.call

        expect(response).to have_http_status(:created)
      end
    end
    context 'with invalid params' do
      context 'password does not match' do
        let(:password) { 'test123' }
        it 'return 422 with errors' do
          action.call

          expect(response).to have_http_status(:unprocessable_entity)
          expect(
            json_response[:errors][0]
          ).to eq "Password confirmation doesn't match Password"
        end
      end
    end
  end
end

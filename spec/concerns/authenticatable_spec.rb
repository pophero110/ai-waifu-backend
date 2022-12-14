require 'rails_helper'

## TODO: stub the request to remove dependency

RSpec.describe Authenticatable, type: :request do
  describe 'authenticatable_request' do
    context 'has no authorization header' do
      it 'return 422' do
        delete sign_out_api_sessions_path
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response[:errors]).to eq('Missing Authorization Header')
      end
    end

    context 'has authorization header' do
      it 'do nothing' do
        delete sign_out_api_sessions_path, headers: { 'Authorization' => 'foo' }

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end

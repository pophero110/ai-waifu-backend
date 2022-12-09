require 'rails_helper'

## TODO: stub the request to remove dependency

RSpec.describe Authenticatable, type: :request do
  describe 'authenticatable_request' do
    context 'has no authorization header' do
      it 'return 400' do
        delete sign_out_path
        expect(response).to have_http_status(400)
        body = JSON.parse(response.body)
        expect(body['errors']).to eq('Missing Authorization Header')
      end
    end

    context 'has authorization header' do
      it 'do nothing' do
        delete sign_out_path, headers: { 'Authorization' => 'foo' }

        expect(response).to have_http_status(400)
      end
    end
  end
end

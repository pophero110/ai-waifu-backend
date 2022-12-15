require 'rails_helper'

RSpec.describe OauthAccessToken, type: :model do
  describe 'association' do
    let(:oauth_access_token) { build(:oauth_access_token) }
    context 'user is not assigned' do
      it 'is not valid' do
        oauth_access_token.user = nil
        expect(oauth_access_token.valid?).to eq false
        expect(oauth_access_token.errors.full_messages).to eq [
             'User must exist'
           ]
      end
    end
  end
  describe 'instance methods' do
    let(:oauth_access_token) { build(:oauth_access_token) }
    context 'expired?' do
      it 'returns true' do
        oauth_access_token.expired_at = 1.hour.ago
        expect(oauth_access_token.expired?).to eq true
      end
      it 'returns false' do
        expect(oauth_access_token.expired?).to eq false
      end
    end
  end
end

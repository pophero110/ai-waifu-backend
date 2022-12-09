FactoryBot.define do
  factory :oauth_access_token do
    token { 'fake_token' }
    refresh_token { 'fake_refresh_token' }
    expired_at { 24.hours.from_now }
  end
end

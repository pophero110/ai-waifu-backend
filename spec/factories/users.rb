# == Schema Information
#
# Table name: users
#
#  id                :bigint           not null, primary key
#  email             :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  confirmed_at      :datetime
#  password_digest   :string
#  unconfirmed_email :string
#  confirmation_code :string
#
FactoryBot.define do
  factory :user do
    email { 'test@gmail.com' }
    password { 'test' }
    confirmed_at { Time.current }
  end
end

# == Schema Information
#
# Table name: oauth_access_tokens
#
#  id            :bigint           not null, primary key
#  token         :text             not null
#  refresh_token :text             not null
#  expired_at    :datetime         not null
#  created_at    :datetime         not null
#  user_id       :bigint
#
class OauthAccessToken < ApplicationRecord
  belongs_to :user, required: true

  def expired?
    expired_at <= Time.current
  end
end

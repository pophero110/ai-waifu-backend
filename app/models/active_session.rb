# == Schema Information
#
# Table name: active_sessions
#
#  id             :bigint           not null, primary key
#  user_id        :bigint           not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  user_agent     :string
#  ip_address     :string
#  remember_token :string           not null
#
class ActiveSession < ApplicationRecord
  belongs_to :user
  has_secure_token :remember_token
end

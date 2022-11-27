# == Schema Information
#
# Table name: likes
#
#  id          :bigint           not null, primary key
#  ai_waifu_id :bigint
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class Like < ApplicationRecord
  belongs_to :ai_waifu
end

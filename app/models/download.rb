# == Schema Information
#
# Table name: downloads
#
#  id          :bigint           not null, primary key
#  ai_waifu_id :bigint
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class Download < ApplicationRecord
  belongs_to :ai_waifu
end

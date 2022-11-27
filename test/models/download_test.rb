# == Schema Information
#
# Table name: downloads
#
#  id          :bigint           not null, primary key
#  ai_waifu_id :bigint
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
require "test_helper"

class DownloadTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end

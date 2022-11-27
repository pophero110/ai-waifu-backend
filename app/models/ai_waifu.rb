# == Schema Information
#
# Table name: ai_waifus
#
#  id         :bigint           not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class AiWaifu < ApplicationRecord
  has_one_attached :image, :dependent => :destroy
  has_many :likes, dependent: :destroy
  has_many :downloads, dependent: :destroy
  paginates_per 9

  def image_url
    if self.image.attached?
      self.image.url
    else
      nil
    end
  end
end

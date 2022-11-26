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

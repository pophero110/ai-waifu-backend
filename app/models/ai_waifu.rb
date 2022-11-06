class AiWaifu < ApplicationRecord
  has_one_attached :image, :dependent => :destroy
  has_many :likes, dependent: :destroy
  has_many :downloads, dependent: :destroy
end

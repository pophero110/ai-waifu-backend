module Api
  class AiWaifuSerializer
    include JSONAPI::Serializer
    attributes :id, :name, :image_url
  end
end

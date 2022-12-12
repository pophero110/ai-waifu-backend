module Api
  class AiWaifusController < BaseController
    skip_before_action :authenticatable_request, only: [:index]

    def index
      @ai_waifus = AiWaifu.includes(:likes, :downloads).order(created_at: :desc)
      render json: @ai_waifus, methods: :image_url
    end
  end
end

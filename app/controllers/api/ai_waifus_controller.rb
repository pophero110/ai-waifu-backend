module Api
  class AiWaifusController < BaseController
    skip_before_action :authenticatable_request, only: [:index]

    def index
      ai_waifus = AiWaifu.order(created_at: :desc)
      render json: AiWaifuSerializer.new(ai_waifus).serializable_hash.to_json
    end
  end
end

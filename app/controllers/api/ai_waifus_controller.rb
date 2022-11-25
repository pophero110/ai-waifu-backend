module Api
    class AiWaifusController < BaseController
        
        def index
            @ai_waifus = AiWaifu.includes(:likes, :downloads).order(created_at: :desc)
            render json: @ai_waifus, methods: :image_url
        end
    end
end
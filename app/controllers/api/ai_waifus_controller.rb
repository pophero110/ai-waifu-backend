module Api
  class AiWaifusController < BaseController
    skip_before_action :authenticatable_request, only: [:index]

    def index
      @ai_waifus = AiWaifu.includes(:likes, :downloads).order(created_at: :desc)
      cookies.signed[:some_cookie] = { value: '123', expires: 1.minute }
      session[:current_user_id] = rand(1000)
      render json: @ai_waifus, methods: :image_url
    end
  end
end

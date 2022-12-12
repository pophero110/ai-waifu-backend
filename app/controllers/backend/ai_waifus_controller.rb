module Backend
  class AiWaifusController < ApplicationController
    USERS = { 'jeff' => 'jiajin' }
    before_action :set_ai_waifu, except: %i[index update new]

    def index
      @ai_waifus = AiWaifu.includes(:likes, :downloads).order(created_at: :desc)
    end

    def new
      @ai_waifu = AiWaifu.new
    end

    def create
      ai_waifu = AiWaifu.create! params.require(:ai_waifu).permit(:name, :image)
      flash[:alert] = ai_waifu.error.messages unless ai_waifu.valid?
      redirect_to ai_waifu
    end

    def show
    end

    def edit
    end

    def update
      ai_waifu = AiWaifu.find(params[:id])
      ai_waifu.update(params.require(:ai_waifu).permit(:name))
      ai_waifu.image.attach(params[:ai_waifu][:image])
      redirect_to ai_waifu
    end

    def destroy
      @ai_waifu.delete
      redirect_to ai_waifus_path
    end

    def like
      @ai_waifu.likes.create
    end

    def download
      @ai_waifu.downloads.create
    end

    private

    def set_ai_waifu
      @ai_waifu = AiWaifu.find(params[:id])
    end
  end
end

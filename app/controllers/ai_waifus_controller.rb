class AiWaifusController < ApplicationController
	http_basic_authenticate_with name: "jeff", password: "jeff123", except: [:index, :show]

	def new
		@ai_waifu = AiWaifu.new
	end

	def create
		ai_waifu = AiWaifu.create! params.require(:ai_waifu).permit(:name, :image)
		redirect_to ai_waifu
	end
	
	def show
		@ai_waifu = AiWaifu.find(params[:id])
	end

	def edit
		@ai_waifu = AiWaifu.find(params[:id])
	end
	
	def index
		@ai_waifus = AiWaifu.all
	end

	def update
		ai_waifu = AiWaifu.find(params[:id])
		ai_waifu.update(params.require(:ai_waifu).permit(:name))
		ai_waifu.image.attach(params[:ai_waifu][:image])
		redirect_to ai_waifu
	end

	def destroy
		@ai_waifu = AiWaifu.find(params[:id])
		@ai_waifu.delete
		redirect_to ai_waifus_path
	end
end

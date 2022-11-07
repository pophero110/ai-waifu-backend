class WelcomeController < ApplicationController
	def index
		@ai_waifus = AiWaifu.includes(:likes, :downloads).order(created_at: :desc)
	end
end

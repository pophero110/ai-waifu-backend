class WelcomeController < ApplicationController
	def index
		@ai_waifus = AiWaifu.includes(:likes)
	end
end

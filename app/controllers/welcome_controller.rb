class WelcomeController < ApplicationController
	def index
		@ai_waifus = AiWaifu.all
	end
end

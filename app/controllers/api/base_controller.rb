module Api
  class BaseController < ApplicationController
    skip_before_action :verify_authenticity_token

    def redirect_if_authenticated
      render json: { logged_in: true } if user_signed_in?
    end
  end
end

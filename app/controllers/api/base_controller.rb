module Api
  class BaseController < ApplicationController
    include ExceptionHandler
    include Authenticatable
    before_action :set_json_header

    def api_user_data
      claims = OauthAccessToken.find_by(access_token: access_token)
      return claims.user if claims
    end

    def re_err(errors, status: :bad_request)
      render json: { errors: errors }, status: status
    end

    def set_json_header
      response['Content-Type'] = 'application/json'
    end
  end
end

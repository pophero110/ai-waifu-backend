class ApplicationController < ActionController::Base
  include Authenticatable
  skip_before_action :verify_authenticity_token

  def api_user_data
    claims = OauthAccessToken.find_by(access_token: access_token)
    return claims.user if claims
  end

  def re_err(errors, hash)
    render json: { errors: errors }, status: hash[:status]
  end
end

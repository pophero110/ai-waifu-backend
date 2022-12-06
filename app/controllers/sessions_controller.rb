class SessionsController < ApplicationController
  skip_before_action :authenticatable_request, only: %i[create update]
  def create
    user =
      User.authenticate_by(
        email: params[:user][:email].downcase,
        password: params[:user][:password]
      )
    if user
      if user.unconfirmed?
        re_err('Email is not confirmed', status: 401)
      elsif user.authenticate(params[:user][:password])
        exp = params[:remember_me] == '1' ? 3.days.from_now : 24.hours.from_now
        oauthToken = Authenticator.sign_in(user, exp)
        render status: 201,
               json: {
                 access_token: oauthToken.token,
                 refresh_token: oauthToken.refresh_token
               }
      else
        re_err('Incorrect email or password', status: 422)
      end
    else
      re_err('Incorrect email or password', status: 422)
    end
  end

  def destroy
    if Authenticator.sign_out(access_token)
      head :ok
    else
      re_err('Invalid Token', status: 401)
    end
  end

  def update
    oauthToken = OauthAccessToken.find_by(refresh_token: params[:refresh_token])
    if oauthToken
      if oauthToken.expired?
        oauthToken.destroy
        re_err('Expired Token', status: 401)
      else
        newToken = Authenticator.refresh_token(oauthToken.user)
        render status: 200,
               json: {
                 access_token: newToken.token,
                 refresh_token: newToken.refresh_token
               }
      end
    else
      re_err('Invalid Token', status: 401)
    end
  end
end

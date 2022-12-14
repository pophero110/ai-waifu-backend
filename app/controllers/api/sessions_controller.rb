module Api
  class SessionsController < BaseController
    skip_before_action :authenticatable_request, only: %i[sign_in refresh_token]

    # TODO: add params require method
    def sign_in
      user =
        User.authenticate_by(
          email: sign_in_params[:email],
          password: sign_in_params[:password]
        )
      if user
        if user.unconfirmed?
          re_err('Email is not confirmed', status: :unprocessable_entity)
        elsif user.authenticate(sign_in_params[:password])
          exp =
            params[:remember_me] == '1' ? 3.days.from_now : 24.hours.from_now
          oauthToken = Authenticator.sign_in(user, exp)
          render status: :created,
                 json: {
                   access_token: oauthToken.token,
                   refresh_token: oauthToken.refresh_token
                 }
        else
          re_err('Incorrect email or password', status: :unprocessable_entity)
        end
      else
        re_err('Incorrect email or password', status: :unprocessable_entity)
      end
    end

    def sign_out
      if Authenticator.sign_out(access_token)
        head :ok
      else
        re_err('Invalid Token', status: :unprocessable_entity)
      end
    end

    def refresh_token
      oauth_access_token = Authenticator.refresh_token(params[:refresh_token])
      if oauth_access_token.present?
        if oauth_access_token.destroyed?
          re_err('Expired Token', status: :unprocessable_entity)
        else
          render status: :ok,
                 json: {
                   access_token: oauth_access_token.token,
                   refresh_token: oauth_access_token.refresh_token
                 }
        end
      else
        re_err('Invalid Token', status: :unprocessable_entity)
      end
    end

    private

    def sign_in_params
      params.permit(:email, :password, :remember_me)
    end
  end
end

module Api
  class SessionsController < BaseController
    before_action :authenticate_user!, only: [:destroy]
    before_action :redirect_if_authenticated, only: [:create]

    def create
      @user = User.authenticate_by(email: params[:user][:email].downcase, password: params[:user][:password])
      if @user
        if @user.unconfirmed?
          render status: 422, json: {
            error: "Email is not confirmed",
            unconfirmed_emai: true,
          }
        elsif @user.authenticate(params[:user][:password])
          active_session = login @user
          if params[:user][:remember_me] == "1"
            remember(active_session)
            render status: 201, json: {
                     logged_in: true,
                     remember_me: true,
                   }
          else
            render status: 201, json: {
                     logged_in: true,
                     remember_me: false,
                   }
          end
        else
          render_error
        end
      else
        render_error
      end
    end

    def destroy
      forget_active_session
      logout
      render json: {
               logged_in: false,
             }
    end

    def is_logged_in?
      if user_signed_in?
        render json: {
                 logged_in: true,
               }
      else
        render json: {
                 logged_in: false,
               }
      end
    end

    private

    def render_error
      render status: 422, json: {
        error: "Incorrect email or password.",
      }
    end
  end
end

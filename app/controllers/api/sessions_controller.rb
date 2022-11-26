module Api
  class SessionsController < BaseController
    before_action :authenticate_user!, only: [:destroy]
    before_action :redirect_if_authenticated, only: [:create]

    def create
      @user = User.authenticate_by(email: params[:user][:email].downcase, password: params[:user][:password])
      if @user
        if @user.unconfirmed?
          redirect_to new_confirmation_path, alert: "Incorrect email or password."
        elsif @user.authenticate(params[:user][:password])
          active_session = login @user
          if params[:user][:remember_me] == "1"
            remember(active_session)
            render json: {
                     logged_in: true,
                     remember_me: true,
                   }
          else
            render json: {
                     logged_in: true,
                     remember_me: false,
                   }
          end
        else
          render json: {
                   status: 422,
                   alert: "Incorrect email or password.",
                 }
        end
      else
        render json: {
                 status: 422,
                 alert: "Incorrect email or password.",
               }
      end
    end

    def destroy
      forget_active_session
      logout
      render json: {
               logged_in: false,
             }
    end
  end
end

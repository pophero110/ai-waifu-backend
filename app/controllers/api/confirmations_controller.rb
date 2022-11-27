module Api
  class ConfirmationsController < BaseController
    before_action :redirect_if_authenticated, only: [:create, :new]

    def create
      @user = User.find_by(email: params[:user][:email].downcase)

      if @user.present? && @user.unconfirmed?
        @user.send_confirmation_email!
        head :ok
      else
        logger.warn "user not found or user's email is not confirmed #{params[:user]&.inspect}"
        render status: :unprocessable_entity, json: { error: "Something went wrong" }
      end
    end

    def edit
      @user = User.find_signed(params[:confirmation_token], purpose: :confirm_email)
      if @user.present?
        if @user.confirm!
          login @user
          head :ok
        else
          render status: :unprocessable_entity, json: { error: "Your email address has been confirmed" }
        end
      else
        render status: :unprocessable_entity, json: { error: "Invalid Token" }
      end
    end
  end
end

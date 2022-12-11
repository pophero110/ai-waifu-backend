module Api
  class PasswordResetsController < BaseController
    before_action :authenticate_request!

    # TODO: password reset api refactor
    # TODO: add params require method
    def create
      @user = User.find_by(email: create_params[:email])
      if @user.present?
        if @user.confirmed?
          EmailVerification.email_confirmation(@user)
          head :ok
        else
          re_err('Email is not confirmed', status: :unprocessable_entity)
        end
      else
        EmailVerification.password_reset(@user)
      end
    end

    def verify
      @user =
        User.find_signed(
          params[:password_reset_token],
          purpose: :reset_password
        )
      if @user.present? && @user.unconfirmed?
        redirect_to new_confirmation_path,
                    alert: 'You must confirm your email before you can sign in.'
      elsif @user.nil?
        redirect_to new_password_path, alert: 'Invalid or expired token.'
      end
    end

    def update
      @user =
        User.find_signed(
          params[:password_reset_token],
          purpose: :reset_password
        )
      if @user
        if @user.unconfirmed?
          redirect_to new_confirmation_path,
                      alert:
                        'You must confirm your email before you can sign in.'
        elsif @user.update(password_params)
          redirect_to login_path, notice: 'Sign in.'
        else
          flash.now[:alert] = @user.errors.full_messages.to_sentence
          render :edit, status: :unprocessable_entity
        end
      else
        flash.now[:alert] = 'Invalid or expired token.'
        render :new, status: :unprocessable_entity
      end
    end

    private

    def create_params
      params.permit(:email)
    end

    def password_params
      params.permit(:password, :password_confirmation)
    end
  end
end

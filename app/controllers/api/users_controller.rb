module Api
  class UsersController < BaseController
    skip_before_action :authenticatable_request, only: %i[sign_up]
    before_action :authenticate_request!, except: %i[sign_up]

    def sign_up
      @user = User.new(create_user_params)
      if @user.save
        EmailVerification.email_confirmation(@user)
        head :created
      else
        render status: :unprocessable_entity,
               json: {
                 errors: @user.errors.full_messages
               }
      end
    end

    def update_account
      @user = current_user
      @active_sessions = @user.active_sessions.order(created_at: :desc)
      if @user.authenticate(update_user_params[:password])
        if @user.update(update_user_params)
          if params[:user][:unconfirmed_email].present?
            @user.send_confirmation_email!
            redirect_to root_path,
                        notice:
                          'Check your email for confirmation instructions.'
          else
            redirect_to root_path, notice: 'Account updated.'
          end
        else
          render :edit, status: :unprocessable_entity
        end
      else
        flash.now[:error] = 'Incorrect password'
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def create_user_params
      params.permit(:email, :password, :password_confirmation)
    end

    def update_user_params
      params.permit(
        :current_password,
        :password,
        :password_confirmation,
        :unconfirmed_email
      )
    end
  end
end

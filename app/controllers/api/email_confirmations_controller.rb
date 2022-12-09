module Api
  class EmailConfirmationsController < BaseController
    skip_before_action :authenticatable_request

    # TODO: implement Rack::Attack to protect Rails from bad clients
    def create
      @user = User.find_by(email: send_params[:email].downcase)

      if @user.present? && @user.unconfirmed?
        @user.send_confirmation_email!
        head :ok
      else
        Rails.logger.warn "user not found or user's email is not confirmed, user: #{@user.inspect}"
        re_err('Something went wrong', status: 422)
      end
    end

    def verify
      @user = User.find_signed(verify_params, purpose: :confirm_email)
      if @user.present?
        if @user.confirms_email?
          redirect_to web_client_login_path(status: '200')
        else
          redirect_to web_client_login_path(
                        status: '422',
                        errors: 'Your email address has been confirmed'
                      )
        end
      else
        redirect_to web_client_email_confirmation_path(
                      status: '422',
                      errors: 'Invalid Confirmation Token'
                    )
      end
    end

    private

    def verify_params
      params.require(:confirmation_token)
    end

    def send_params
      params.require(:user).permit(:email)
    end
  end
end

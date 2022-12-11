module Api
  class EmailConfirmationsController < BaseController
    skip_before_action :authenticatable_request

    # TODO: implement Rack::Attack to protect Rails from bad clients
    def create
      @user = User.find_by(email: create_params[:email].downcase)
      if @user.present? && @user.unconfirmed?
        EmailVerification.email_confirmation(@user)
        head :ok
      else
        Rails.logger.warn "user's email is not found or confirmed: #{create_params[:email]}"
        re_err('Something went wrong', status: :unprocessable_entity)
      end
    end

    def verify
      @user =
        User.find_signed(
          verify_params[:confirmation_token],
          purpose: :confirm_email
        )
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
      params.permit(:confirmation_token)
    end

    def create_params
      params.permit(:email)
    end
  end
end

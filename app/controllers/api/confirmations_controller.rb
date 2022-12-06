module Api
  class ConfirmationsController < BaseController
    skip_before_action :authenticatable_request

    # TODO: implement Rack::Attack to protect Rails from bad clients
    def create
      @user = User.find_by(email: params[:user][:email].downcase)

      if @user.present? && @user.unconfirmed?
        @user.send_confirmation_email!
        head :ok
      else
        logger.warn "user not found or user's email is not confirmed #{params[:user]&.inspect}"
        re_err('Something went wrong', status: 400)
      end
    end

    def update
      @user =
        User.find_signed(params[:confirmation_token], purpose: :confirm_email)
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
                      status: '400',
                      errors: 'Invalid Confirmation Token'
                    )
      end
    end
  end
end

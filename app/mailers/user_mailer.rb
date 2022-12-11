class UserMailer < ApplicationMailer
  default from: User::MAILER_FROM_EMAIL
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.confirmation.subject
  #
  # TODO: add mail preview to check view

  def email_confirmation(email, confirmation_token)
    @confirmation_token = confirmation_token

    mail to: email, subject: 'Email Confirmation Instructions'
  end

  def password_reset(email, password_reset_token)
    @password_reset_token = password_reset_token

    mail to: email, subject: 'Password Reset Instructions'
  end
end

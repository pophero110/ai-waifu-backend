class EmailVerification
  def self.email_confirmation(user)
    UserMailer.email_confirmation(
      user.confirmable_email,
      user.generate_confirmation_token
    )
  end

  def self.password_reset
    UserMailer.password_reset(user.email, user.generate_password_reset_token)
  end
end

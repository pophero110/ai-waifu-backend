class EmailSender
  def self.email_confirmation(user)
    UserMailer.email_confirmation(
      user.confirmable_email,
      user.generate_confirmation_token
    ).deliver_now
  end

  def self.password_reset(user)
    UserMailer.password_reset(
      user.email,
      user.generate_password_reset_token
    ).deliver_now
  end
end

# == Schema Information
#
# Table name: users
#
#  id                :bigint           not null, primary key
#  email             :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  confirmed_at      :datetime
#  password_digest   :string
#  unconfirmed_email :string
#  confirmation_code :string
#
class User < ApplicationRecord
  CONFIRMATION_TOKEN_EXPIRATION = 10.minutes
  PASSWORD_RESET_TOKEN_EXPIRATION = 10.minutes
  MAILER_FROM_EMAIL = 'no-reply@example.com'

  has_one :oauth_access_token, dependent: :destroy

  attr_accessor :current_password

  has_secure_password

  before_save :downcase_email
  before_save :downcase_unconfirmed_email

  validates :email,
            format: {
              with: URI::MailTo::EMAIL_REGEXP
            },
            presence: true,
            uniqueness: true

  def self.authenticate_by(attributes)
    passwords, identifiers =
      attributes
        .to_h
        .partition do |name, value|
          !has_attribute?(name) && has_attribute?("#{name}_digest")
        end
        .map(&:to_h)

    if passwords.empty?
      raise ArgumentError, 'One or more password arguments are required'
    end
    if identifiers.empty?
      raise ArgumentError, 'One or more finder arguments are required'
    end

    return if passwords.any? { |name, value| value.nil? || value.empty? }

    if record = find_by(identifiers)
      if passwords.count { |name, value|
           record.public_send(:"authenticate_#{name}", value)
         } == passwords.size
        record
      end
    else
      new(passwords)
      nil
    end
  end

  def confirms_email?
    if email_unconfirmed_or_reconfirming?
      if unconfirmed_email.present?
        return(
          update(
            confirmed_at: Time.current,
            email: unconfirmed_email,
            unconfirmed_email: nil
          )
        )
      end

      return update(confirmed_at: Time.current)
    end
  end

  def confirmable_email
    unconfirmed_email.present? ? unconfirmed_email : email
  end

  def confirmed?
    confirmed_at.present?
  end

  def unconfirmed?
    !confirmed?
  end

  def generate_confirmation_token
    signed_id expires_in: CONFIRMATION_TOKEN_EXPIRATION, purpose: :confirm_email
  end

  def generate_password_reset_token
    signed_id expires_in: PASSWORD_RESET_TOKEN_EXPIRATION,
              purpose: :reset_password
  end

  private

  def downcase_email
    self.email = email.downcase
  end

  def downcase_unconfirmed_email
    return if unconfirmed_email.nil?
    self.unconfirmed_email = unconfirmed_email.downcase
  end

  def reconfirming?
    unconfirmed_email.present?
  end

  def email_unconfirmed_or_reconfirming?
    unconfirmed? || reconfirming?
  end
end

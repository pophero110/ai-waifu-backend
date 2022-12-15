module UserValidation
  extend ActiveSupport::Concern

  included do
    validates :email,
              format: {
                with: URI::MailTo::EMAIL_REGEXP
              },
              presence: true,
              uniqueness: true

    validates :password,
              length: {
                minimum: 8
              },
              format: {
                with: PASSWORD_FORMAT
              }
  end

  private

  PASSWORD_FORMAT =
    /\A
  (?=.{8,})          # Must contain 8 or more characters
  (?=.*\d)           # Must contain a digit
  (?=.*[a-z])        # Must contain a lower case character
  (?=.*[A-Z])        # Must contain an upper case character
  (?=.*[[:^alnum:]]) # Must contain a symbol
  /x
end

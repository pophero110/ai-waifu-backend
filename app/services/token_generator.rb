class TokenGenerator
  def self.access_token(payload, exp = 24.hours.from_now)
    payload[:exp] = exp.to_i
    access_token = JWT.encode(payload, ENV['RAILS_SECRECT_BASE'])
    access_token
  end

  def self.refresh_token
    loop do
      refresh_token = SecureRandom.urlsafe_base64(nil, false)
      unless OauthAccessToken.exists?(refresh_token: refresh_token)
        break refresh_token
      end
    end
  end

  def self.verify(access_token)
    body = JWT.decode(access_token, ENV['RAILS_SECRECT_BASE'])[0]
    HashWithIndifferentAccess.new body
  end
end

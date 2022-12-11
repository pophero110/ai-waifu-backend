class Authenticator
  TOKEN_EXPIRED_DURATION = 24.hours.from_now

  def self.sign_in(user, exp = TOKEN_EXPIRED_DURATION)
    return user.oauth_access_token if user.oauth_access_token.present?

    return(
      OauthAccessToken.create!(
        token: TokenGenerator.access_token({ user_id: user.id }, exp),
        refresh_token: TokenGenerator.refresh_token,
        expired_at: exp,
        user: user
      )
    )
  end

  def self.sign_out(access_token)
    begin
      body = TokenGenerator.verify(access_token)
      return false if body.nil?

      user = User.find(body['user_id'])

      if user.oauth_access_token.present?
        user.oauth_access_token.destroy
        return true
      else
        return false
      end
    rescue JWT::ExpiredSignature
      Rails.logger.warn("Expired token - access_token: #{access_token}")
      return false
    rescue => e
      Rails.logger.warn(
        "Sign out exception - access_token: #{access_token} Exception: #{e.message}"
      )
      return false
    end
  end

  def self.refresh_token(user)
    oauth_token_attributes = {
      token: TokenGenerator.access_token({ user_id: user.id }),
      refresh_token: TokenGenerator.refresh_token,
      expired_at: TOKEN_EXPIRED_DURATION
    }
    user.oauth_access_token.update!(oauth_token_attributes)

    return(
      OpenStruct.new(
        {
          token: oauth_token_attributes['token'],
          refresh_token: oauth_token_attributes['refresh_token']
        }
      )
    )
  end

  def self.authorize(access_token)
    begin
      body = TokenGenerator.verify(access_token)
      return false if body.nil?

      user = User.find(body['user_id'])
      user
    end
  end
end

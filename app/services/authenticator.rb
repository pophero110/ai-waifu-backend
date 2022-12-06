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
    rescue ActiveRecord::RecordNotFound
      Rails.logger.warn("User not found - access_token: #{access_token}")
      return false
    rescue => e
      Rails.logger.warn(
        "Sign out exception - access_token: #{access_token} exception: #{e}"
      )
      return false
    end
  end

  def self.refresh_token(user)
    oauthToken = user.oauth_access_token

    exp = Time.current + (oauthToken.expired_at - Time.current) - 1.second
    access_token = TokenGenerator.access_token({ user_id: user.id }, exp)
    refresh_token = TokenGenerator.refresh_token

    oauthToken.update!(
      token: access_token,
      refresh_token: refresh_token,
      expired_at: exp
    )

    return OpenStruct.new({ token: access_token, refresh_token: refresh_token })
  end

  def self.authorize(access_token)
    begin
      body = TokenGenerator.verify(access_token)
      return false if body.nil?

      user = User.find(body['user_id'])
      return user
    end
  end
end

class Authenticator
  ACCESS_TOKEN_EXPIRED_DURATION = 8.hours.from_now
  REFRESH_TOEKN_EXPIRED_DURATION = 24.hours.from_now
  def self.sign_in(user, exp = ACCESS_TOKEN_EXPIRED_DURATION)
    return user.oauth_access_token if user.oauth_access_token.present?

    return(
      OauthAccessToken.create!(
        token: TokenGenerator.access_token({ user_id: user.id }, exp),
        refresh_token: TokenGenerator.refresh_token,
        expired_at: REFRESH_TOEKN_EXPIRED_DURATION,
        user: user
      )
    )
  end

  def self.sign_out(access_token)
    body = TokenGenerator.verify(access_token)
    return false if body.nil?

    user = User.find(body['user_id'])

    if user.oauth_access_token.present?
      user.oauth_access_token.destroy
      return true
    else
      return false
    end
  rescue JWT::ExpiredSignature => e
    Rails.logger.warn("Expired token: #{access_token}")
    return false
  end

  def self.refresh_token(refresh_token)
    oauth_access_token = OauthAccessToken.find_by(refresh_token: refresh_token)
    if oauth_access_token.present?
      return oauthToken.destroy if oauth_access_token.expired?
      # Refresh Token Rotaion to avoid malicious users
      new_oauth_token_attributes = {
        token:
          TokenGenerator.access_token({ user_id: oauth_access_token.user_id }),
        refresh_token: TokenGenerator.refresh_token
      }
      oauth_access_token.update!(new_oauth_token_attributes)
    end
    return oauth_access_token
  end
end

module Authenticatable
  extend ActiveSupport::Concern

  included { before_action :authenticatable_request }

  def access_token
    request.authorization.split(' ').last
  end

  def authenticatable_request
    unless request.authorization.present?
      re_err 'Missing Authorization Header', status: 400
    end
  end

  def authenticate_request!
    TokenGenerator.verify(access_token)
  rescue => e
    Rails.warn("autneticate_request exception - #{e}")
    head :unauthorized
  end
end

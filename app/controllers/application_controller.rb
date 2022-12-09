class ApplicationController < ActionController::Base
  include Authenticatable
  skip_before_action :verify_authenticity_token
end

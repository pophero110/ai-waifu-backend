class ApplicationController < ActionController::Base
  skip_before_action :verify_authenticity_token
  #TODO: make profile for declaring how to boot server on production
end

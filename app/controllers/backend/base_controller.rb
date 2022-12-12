module Backend
  class BaseController < ApplicationController
    http_basic_authenticate_with name: ENV['ADMIN'], password: ENV['ADMIN_PASS']
  end
end

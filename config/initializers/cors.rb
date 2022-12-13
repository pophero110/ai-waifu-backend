Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins 'localhost:4000', 'http://www.freewaifuanimepicture.com'
    resource '*', headers: :any, methods: %i[get post patch put delete]
  end
end

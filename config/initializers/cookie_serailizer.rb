Rails.application.config.action_dispatch.cookies_serializer = :hybrid
#config/initializers/session_store.rb
if Rails.env === "production"
  Rails.application.config.session_store :cookie_store, expire_after: 6.days, key: "_free_ai_anime_waifu_sesssion", domain: "heroku"
else
  Rails.application.config.session_store :cookie_store, expire_after: 6.days, key: "_local_free_ai_anime_waifu_sesssion", domain: "heroku:local"
end

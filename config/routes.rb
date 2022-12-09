Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  root 'welcome#index'

  # redirect user to web client
  namespace :web_client do
    get '/login',
        to: redirect { |params, request| 'http://localhost:4000/login' }
    get '/email_confirmation',
        params: %i[status errors],
        to:
          redirect { |params, request|
            "http://localhost:4000/email_confirmation?status=#{params[:status]}&errors=#{params[:errors]}"
          }
  end

  namespace :api do
    resources :ai_waifus do
      post 'like', on: :member
      post 'download', on: :member
    end

    resources :user, only: %i[update destroy] do
      post :sign_up
    end

    resources :email_confirmations, only: %i[create] do
      get :verify, param: :confirmation_token, on: :collection
    end

    resource :password_reset, only: %i[create] do
      get :verify, param: :password_reset_token, on: :collection
    end

    resources :sessions, only: %i[] do
      collection do
        post :sign_in
        delete :sign_out
        put :refresh_token
      end
    end
  end
end

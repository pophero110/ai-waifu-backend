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

    post 'sign_up', to: 'users#create'
    put 'account', to: 'users#update'
    delete 'account', to: 'users#destroy'

    post 'send_email_confirmation', to: 'confirmations#create'
    get 'confirm_email', to: 'confirmations#update', param: :confirmation_token
  end

  scope :oauth do
    post 'sign_in', to: 'sessions#create'
    delete 'sign_out', to: 'sessions#destroy'
    put 'refresh_token', to: 'sessions#update'
  end
end

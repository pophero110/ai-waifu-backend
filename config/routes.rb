Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  root 'welcome#index'

  post "sign_up", to: "users#create"
  get "sign_up", to: "users#new"
  put "account", to: "users#update"
  get "account", to: "users#edit"
  delete "account", to: "users#destroy"

  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy"
  get "login", to: "sessions#new"

  resources :confirmations, only: [:create, :edit, :new], param: :confirmation_token
  resources :ai_waifus do
    post 'like', on: :member
    post 'download', on: :member
  end
  resources :passwords, only: [:create, :edit, :new, :update], param: :password_reset_token

  resources :active_sessions, only: [:destroy] do
    collection do
      delete "destroy_all"
    end
  end

  namespace :api do 
    resources :ai_waifus
  end
end

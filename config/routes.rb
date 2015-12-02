Rails.application.routes.draw do
  devise_for :users
  
  root "static_pages#home"
  get "about" => "static_pages#about"
  get "help" => "static_pages#help"

  get "dispatcher" => "request_dispatcher#main"
  get "error_pages" => "error_pages#error"

  namespace :supplier do
  	get "profile" => "home#index"
    resources :vehicles
    resources :requests, only: [:show]
  end

  namespace :admin do
    get "home" => "home#index"
  end

  namespace :customer do
    resources :requests
    get "profile" => "profile#show"
  end
end

Rails.application.routes.draw do
  devise_for :users
  
  root "static_pages#home"
  get "about" => "static_pages#about"
  get "help" => "static_pages#help"

  get "dispatcher" => "request_dispatcher#main"
  get "error/index"
  get "application" => "request_dispatcher#app_dispatcher"

  namespace :supplier do
  	get "profile" => "home#index"
    post "approve_request" => "requests#approve"
    resources :vehicles
    resources :requests   
  end

  namespace :admin do
    get "home" => "home#index"
  end

  namespace :customer do
    resources :requests
    resources :invoices
    post "accept_invoice" => "invoices#accept"
    get "profile" => "profile#show"
  end
end

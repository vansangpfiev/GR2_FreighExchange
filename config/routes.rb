Rails.application.routes.draw do
  devise_for :users
  root "static_pages#home"

  namespace :supplier do
  	get "profile" => "profile#show"
    get "vehicles" => "vehicle#index"
  end

  namespace :admin do
    get "home" => "home#index"
  end

  namespace :customer do
    resources :requests
    get "profile" => "profile#show"
  end
end

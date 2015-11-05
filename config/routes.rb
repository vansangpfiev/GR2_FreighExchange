Rails.application.routes.draw do
  root "static_pages#home"

  namespace :supplier do
  	get "profile" => "profile#index"
    get "vehicles" => "vehicle#index"
  end

  namespace :admin do
    get "home" => "home#index"
  end
end

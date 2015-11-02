Rails.application.routes.draw do
  root "static_pages#home"

  namespace :supplier do
  	get "profile" => "profile#index"
  end
end

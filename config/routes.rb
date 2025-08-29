Rails.application.routes.draw do
  # Devise handles all authentication automatically
  devise_for :users

  # Root route
  root "stations#index"

  # Charging Stations routes
  resources :stations, only: [:index, :show]

  # Reviews
  resources :reviews do
    member do
      post "like"
    end
  end

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check
end

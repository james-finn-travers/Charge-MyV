Rails.application.routes.draw do
  get "users/new"
  get "users/create"
  get "users/create"
  get "users/Show"

  devise_for :users

  # Root route
  root "stations#index"

  # Authentication routes
  get "/login", to: "sessions#new", as: :new_session
  post "/login", to: "sessions#create", as: :session
  delete "/logout", to: "sessions#destroy", as: :destroy_session


  # Charging Stations routes
  get "/find_stations", to: "stations#index", as: :find_stations
  get "/charging_stations", to: "stations#index", as: :charging_stations
  get "/charging_stations/:id", to: "stations#show", as: :station
  get "/charging_stations/:id", to: "stations#show", as: :charging_station


  # User management
  get "/signup", to: "users#new"
  post "/signup", to: "users#create"
  get "/profile", to: "users#show"

  # Resource routes
  resources :stations, only: [ :index ]
  resources :charging_stations
  resources :reviews do
    member do
      post "like"
    end
  end

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check
end

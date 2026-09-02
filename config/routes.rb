Rails.application.routes.draw do
  # Swagger Documentation Engine
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'

  # Devise routes
  devise_for :users, skip: [:sessions, :registrations]

  # API v1 Namespace
  namespace :api do
    namespace :v1 do
      post 'auth/login', to: 'auth#login'

      resources :stations, only: [:index, :show] do
        collection do
          post 'bulk', to: 'stations#bulk_create'
        end
      end

      resources :reviews, only: [:create, :update, :destroy] do
        member do
          post 'like'
        end
      end
    end
  end

  # Health check endpoint
  get 'up', to: 'rails/health#show', as: :rails_health_check

  # Root route redirects to Swagger API docs
  root to: redirect('/api-docs')
end

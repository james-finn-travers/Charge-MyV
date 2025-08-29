class ApplicationController < ActionController::Base
  # Devise handles authentication automatically
  before_action :authenticate_user!
  
  # Add any custom before_actions here if needed
  # before_action :configure_permitted_parameters, if: :devise_controller?

  private

  # If you need to customize Devise parameters, uncomment this:
  # def configure_permitted_parameters
  #   devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name])
  #   devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name])
  # end
end
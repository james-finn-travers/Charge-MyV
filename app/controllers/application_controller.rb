class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  helper_method :current_user, :logged_in?

  def current_user
    @current_user ||= begin
      User.find(session[:user_id]) if session[:user_id]
    rescue ActiveRecord::RecordNotFound
      session[:user_id] = nil
      nil
    end
  end

  def logged_in?
    !!current_user
  end

  def sign_in(user)
    session[:user_id] = user.id
    @current_user = user
    charging_stations_path
  end

  def sign_out
    session[:user_id] = nil
    @current_user = nil
  end

  def authenticate_user!
    unless logged_in?
      flash[:alert] = "Please sign in to continue"
      redirect_to new_session_path
    end
  end
end
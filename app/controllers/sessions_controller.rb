class SessionsController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :new, :create ]
  before_action :redirect_if_authenticated, only: [ :new, :create ]

  def new
  end

  def create
    user = User.find_by(email: params[:email])
    if user&.authenticate(params[:password])
      sign_in(user)
      redirect_to find_stations_path, notice: "Signed in successfully!" # Changed from root_path
    else
      flash.now[:alert] = "Invalid email or password"
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    sign_out
    redirect_to root_path, notice: "Signed out successfully!"
  end

  private

  def redirect_if_authenticated
    redirect_to find_stations_path, notice: "You are already signed in." if logged_in?
  end
end

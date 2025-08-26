class UsersController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :new, :create ]

  # GET /signup
  # Displays the registration form
  def new
    @user = User.new
  end

  # POST /signup
  # Creates a new user account
  def create
    @user = User.new(user_params)
    if @user.save
      sign_in(@user)
      redirect_to find_stations_path, notice: "Account created successfully!" # Changed from root_path
    else
      # Show specific validation errors
      flash.now[:alert] = @user.errors.full_messages.to_sentence
      render :new, status: :unprocessable_entity
    end
  end

  # GET /profile
  # Shows the current user's profile
  def show
    @user = current_user
    # Redirect if user somehow reaches here without being logged in
    redirect_to login_path, alert: "Please sign in first" unless @user
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end

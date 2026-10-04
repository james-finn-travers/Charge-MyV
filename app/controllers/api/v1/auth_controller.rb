module Api
  module V1
    class AuthController < BaseController
      def login
        user = User.find_by(email: params[:email])

        authenticated = user.present? && (
          (user.respond_to?(:valid_password?) && user.valid_password?(params[:password])) ||
          (user.respond_to?(:authenticate) && user.authenticate(params[:password]))
        )

        if authenticated
          expires_at = 24.hours.from_now
          secret = ENV.fetch("JWT_SECRET", Rails.application.secret_key_base)
          payload = {
            user_id: user.id,
            exp: expires_at.to_i
          }
          token = JWT.encode(payload, secret, "HS256")
          render json: {
            token: token,
            expires_at: expires_at.iso8601
          }, status: :ok
        else
          render json: { error: "Invalid email or password" }, status: :unauthorized
        end
      end
    end
  end
end

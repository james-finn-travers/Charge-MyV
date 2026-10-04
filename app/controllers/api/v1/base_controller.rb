module Api
  module V1
    class BaseController < ApplicationController
      attr_reader :current_user

      def authenticate_request!
        header = request.headers["Authorization"]
        token = header.to_s.split(" ").last if header.present?

        if token.blank?
          render json: { error: "Unauthorized: Missing token" }, status: :unauthorized
          return
        end

        secret = ENV.fetch("JWT_SECRET", Rails.application.secret_key_base)
        decoded = JWT.decode(token, secret, true, { algorithm: "HS256" })
        payload = decoded.first
        @current_user = User.find(payload["user_id"])
      rescue JWT::DecodeError, ActiveRecord::RecordNotFound => e
        render json: { error: "Unauthorized: #{e.message}" }, status: :unauthorized
      end
    end
  end
end

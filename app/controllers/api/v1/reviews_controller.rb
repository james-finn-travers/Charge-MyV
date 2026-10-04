module Api
  module V1
    class ReviewsController < BaseController
      before_action :authenticate_request!

      def create
        render json: { message: "Review created successfully" }, status: :created
      end

      def update
        render json: { message: "Review updated successfully" }, status: :ok
      end

      def destroy
        render json: { message: "Review deleted successfully" }, status: :ok
      end

      def like
        render json: { message: "Review liked successfully" }, status: :ok
      end
    end
  end
end

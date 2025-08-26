class ReviewsController < ApplicationController
  def like
    @review = Review.find(params[:id])
    @review.increment!(:likes_count)

    respond_to do |format|
      format.html { redirect_back(fallback_location: root_path) }
      format.json { render json: { likes: @review.likes_count } }
      format.turbo_stream
    end
  end
end
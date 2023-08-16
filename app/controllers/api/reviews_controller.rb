class Api::ReviewsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_admin, only: [:admin_delete_review]

  def index
    @book = Book.find(params[:book_id])
    render json: @book.reviews, status: :ok
  end

  def create
    @book = Book.find(params[:book_id])
    @review = @book.reviews.new(review_params)
    @review.user = @current_user

    if @review.save
      render json: @review, status: :created
    else
      render json: { errors: @review.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    @book = Book.find(params[:book_id])
    @review = @book.reviews.find_by(user: @current_user)

    return render json: { error: 'Book not found' }, status: :not_found unless @book
    return render json: { error: 'User has not reviewed this book yet' }, status: :unprocessable_entity unless @review

    if @review.update(review_params)
      render json: @review, status: :ok
    else
      render json: { errors: @review.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def delete
    @book = Book.find(params[:book_id])
    @review = @book.reviews.find_by(user: @current_user)

    if @review
      @review.destroy
      @review.book.update_average_rating
      head :no_content
    else
      render json: { error: 'User has not reviewed this book yet' }, status: :unprocessable_entity
    end
  end

  def admin_delete_review
    @review = Review.find(params[:id])
    @review.destroy
    @review.book.update_average_rating
    head :no_content
  end

  private

  def review_params
    params.require(:review).permit(:body, :rating)
  end
end

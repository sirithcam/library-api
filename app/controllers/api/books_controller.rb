class Api::BooksController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_admin, only: %i[create update destroy]

  def create
    @book = Book.new(book_params)

    if book_unique?
      if @book.save
        render json: @book, status: :created
      else
        render json: { errors: @book.errors.full_messages }, status: :unprocessable_entity
      end
    else
      render json: { error: 'A book with the same title and author already exists.' }, status: :unprocessable_entity
    end
  end

  def show
    @book = Book.find(params[:id])
    render json: @book, status: :ok
  end

  def index
    @books = Book.order(id: :asc)
    render json: @books, status: :ok
  end

  def update
    @book = Book.find(params[:id])

    if book_unique?
      if @book.update(book_params)
        render json: @book, status: :created
      else
        render json: { errors: @book.errors.full_messages }, status: :unprocessable_entity
      end
    else
      render json: { error: 'A book with the same title and author already exists.' }, status: :unprocessable_entity
    end
  end

  def destroy
    @book = Book.find_by(id: params[:id])

    if @book
      @book.destroy
      render json: { message: 'Book deleted successfully' }, status: :ok
    else
      render json: { error: 'Book not found' }, status: :not_found
    end
  end

  def search
    @books = apply_search_filters.order(id: :asc)
    render json: @books, status: :ok
  end

  private

  def book_params
    params.require(:book).permit(:title, :author, :genre, :release_date)
  end

  def authenticate_user!
    token = request.headers['Authorization']&.split(' ')&.last
    if token
      decoded_payload = AuthService.decode_token(token)
      @user = User.find(decoded_payload['user_id'])
      if token == @user.token
        @current_user = @user
      else
        render json: { error: 'Unauthorized' }, status: :unauthorized
      end
    else
      render json: { error: 'Authorization token missing' }, status: :unauthorized
    end
  end

  def authorize_admin
    return if @current_user.admin?

    render json: { error: 'Unauthorized. Only admins can perform this action.' }, status: :unauthorized
  end

  def book_unique?
    existing_book = Book.where.not(id: @book.id).find_by(title: book_params[:title], author: book_params[:author])
    !existing_book
  end

  def apply_search_filters
    filters = {}

    filters[:author] = params[:author] if params[:author].present?
    filters[:genre] = params[:genre] if params[:genre].present?
    filters[:title] = params[:title] if params[:title].present?
    filters[:release_date] = (params[:from_release_date]..params[:to_release_date]) if params[:from_release_date] && params[:to_release_date]

    if params[:min_rating].present? && params[:max_rating].present?
      filters[:rating] = params[:min_rating].to_f..params[:max_rating].to_f
    elsif params[:min_rating].present?
      filters[:rating] = params[:min_rating].to_f..10.0
    elsif params[:max_rating].present?
      filters[:rating] = 0.0..params[:max_rating].to_f
    end

    Book.where(filters)
  end
end

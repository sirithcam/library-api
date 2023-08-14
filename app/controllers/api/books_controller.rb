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
    existing_book = Book.find_by(title: @book.title, author: @book.author)
    !existing_book
  end
end

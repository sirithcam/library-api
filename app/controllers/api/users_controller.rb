class Api::UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :authenticate_admin!, only: [:index]

  def index
    @users = User.order(id: :asc)
    render json: @users, status: :ok
  end

  def show
    if @current_user.id == params[:id].to_i || @current_user.admin?
      @user = User.find(params[:id])
      render json: @user, status: :ok
    else
      render json: { error: 'Unauthorized' }, status: :unauthorized
    end
  end

  def update
    if @current_user.id == params[:id].to_i || @current_user.admin?
      @user = User.find(params[:id])

      if @user.update(user_params)
        render json: @user, status: :ok
      else
        render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
      end
    else
      render json: { error: 'Unauthorized' }, status: :unauthorized
    end
  end

  def destroy
    @user = User.find(params[:id])

    if @user == @current_user || @current_user.admin?
      @user.destroy
      render json: { message: 'User account deleted successfully' }, status: :ok
    else
      render json: { error: 'Unauthorized' }, status: :unauthorized
    end
  end

  private

  def authenticate_user!
    token = request.headers['Authorization']&.split(' ')&.last
    if token
      decoded_payload = AuthService.decode_token(token)
      if decoded_payload
        @current_user = User.find(decoded_payload['user_id'])
      else
        render json: { error: 'Unauthorized' }, status: :unauthorized
      end
    else
      render json: { error: 'Authorization token missing' }, status: :unauthorized
    end
  end

  def authenticate_admin!
    unless @current_user.admin?
      render json: { error: 'You do not have permission to access this resource' }, status: :forbidden
    end
  end

  def user_params
    params.require(:user).permit(:firstname, :lastname, :email)
  end
end

class Api::UsersController < ApplicationController
  before_action :authenticate_user, only: [:show, :update]

  def show
    if @current_user.id == params[:id].to_i
      render json: @current_user, status: :ok
    else
      render json: { error: 'Unauthorized' }, status: :unauthorized
    end
  end

  def update
    puts "ugabuga"
    if @current_user.id == params[:id].to_i || @current_user.admin?
      user = User.find(params[:id])

      if user.update(user_params)
        render json: user, status: :ok
      else
        render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
      end
    else
      render json: { error: 'Unauthorized' }, status: :unauthorized
    end
  end


  private

  def authenticate_user
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

  def user_params
    params.require(:user).permit(:firstname, :lastname, :email)
  end
end

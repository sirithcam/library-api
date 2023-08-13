# frozen_string_literal: true

class Api::Users::PasswordsController < Devise::PasswordsController
  before_action :authenticate_user, only: [:update]
  # GET /resource/password/new
  # def new
  #   super
  # end

  # POST /resource/password
  # def create
  #   super
  # end

  # GET /resource/password/edit?reset_password_token=abcdef
  # def edit
  #   super
  # end

  # PUT /resource/password
  def update
    user = @current_user
    puts user

    if user&.valid_password?(params[:current_password])
      if user.update(password: params[:password], password_confirmation: params[:password_confirmation])
        render json: { message: 'Password changed successfully' }, status: :ok
      else
        render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
      end
    else
      render json: { error: 'Invalid current password' }, status: :unauthorized
    end
  end

  # protected

  # def after_resetting_password_path_for(resource)
  #   super(resource)
  # end

  # The path used after sending reset password instructions
  # def after_sending_reset_password_instructions_path_for(resource_name)
  #   super(resource_name)
  # end
  private

  def user_params
    params.permit(:password, :current_password, :password_confirmation)
  end

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
end

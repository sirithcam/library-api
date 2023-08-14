# frozen_string_literal: true

class Api::Users::SessionsController < Devise::SessionsController
  def create
    @user = User.find_by(email: params[:email])

    if @user && @user.valid_password?(params[:password])
      payload = { user_id: @user.id }
      token = AuthService.encode_token(payload)

      @user.update(token: token) # Store the token in the user record
      render json: { token: token }, status: :ok
    else
      render json: { error: 'Invalid email or password' }, status: :unauthorized
    end
  end
end

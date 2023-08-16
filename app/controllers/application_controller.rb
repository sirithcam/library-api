class ApplicationController < ActionController::API
  private

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
end

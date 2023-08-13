class AuthService
  SECRET_KEY = Rails.application.secrets.secret_key_base

  def self.encode_token(payload)
    JWT.encode(payload, SECRET_KEY)
  end

  def self.decode_token(token)
    JWT.decode(token, SECRET_KEY).first
  rescue JWT::DecodeError
    nil
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

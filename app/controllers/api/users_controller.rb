class Api::UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_admin, only: [:index, :promote]

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

  def promote
    @user = User.find(params[:id])

    if @user.update(admin: !@user.admin)
      action = @user.admin ? 'promoted' : 'demoted'
      render json: { message: "User #{action} successfully" }, status: :ok
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def logout
    @current_user.update(token: nil)
    render json: { message: 'Logged out successfully' }, status: :ok
  end

  private

  def user_params
    params.require(:user).permit(:firstname, :lastname, :email)
  end
end

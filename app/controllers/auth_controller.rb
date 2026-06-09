class AuthController < ApplicationController

  def signup
    user = User.find_by(email: user_params[:email])
    return render json: { error: 'User already registered'}, status: :unprocessable_entity if user.present?

    ActiveRecord::Base.transaction do
      user = User.create!(user_params)
      generate_access_token(user)
    end
  rescue => e
    render json: {error: 'Unable to perform required action'}, status: 500
  end

  def login
    user = User.find_by(email: user_params[:email])
    return render json: { error: 'User not found'}, status: :unprocessable_entity unless user.present?

    if user.try(:valid_password?, user_params[:password])
      generate_access_token(user)
    else
      render json: { error: 'Invalid Password'}, status: :unprocessable_entity
    end
  rescue => e
    render json: {error: 'Unable to perform required action'}, status: 500
  end

  private

  def user_params
    params.require(:user).permit(:email, :password)
  end

  def generate_access_token(user)
    access_token = Doorkeeper::AccessToken.create(
      resource_owner_id: user.id,
      expires_in: Doorkeeper.configuration.access_token_expires_in.to_i,
      scopes: 'user',
      use_refresh_token: true
    )
    render json: {
      access_token: access_token.token,
      token_type: 'bearer',
      expires_in: access_token.expires_in,
      refresh_token: access_token.refresh_token,
      created_at: access_token.created_at
    }
  end

end

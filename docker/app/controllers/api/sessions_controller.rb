#
# Validates whether or not there is there a valid session
#
class Api::SessionsController < ApplicationController
  skip_before_action :authenticate_user!
  skip_forgery_protection only: :destroy

  def create
    if request.env['omniauth.auth']
      # oauth login
      @user = User.find_for_oauth(request.env['omniauth.auth'])
      session[:user_id] = @user.id
      redirect_to Rails.application.config.ui_host
    else
      # password login
      @user = User.find_by(username: session_params[:username]).try(:authenticate, session_params[:password])

      if @user
        session[:user_id] = @user.id
        render json: {}, status: :ok
      else
        session[:user_id] = nil
        render json: {}, status: :unauthorized
      end
    end
  end

  # Nav helper
  #
  # GET /sessions
  #
  def index
    if @user = current_user
      render json: @user
    else
      render json: {}, status: :unauthorized
    end
  end

  # Nav helper
  #
  # GET /sessions/*
  #
  def show
    if user = current_user

      nav_items = user.get_nav_paths

      user_data = {
        user_data: { name: user.name, username: user.username, email_hash: Digest::MD5.hexdigest(user.username) },
        nav_items: nav_items
      }

      render json: user_data
    else
      render json: {}, status: :unauthorized
    end
  end

  # DELETE /sessions
  def destroy
    session[:user_id] = nil
    render json: {}, status: :ok
  end

  private

  def session_params
    params.require(:session).permit(:username, :password)
  end
end

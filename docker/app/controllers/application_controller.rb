class ApplicationController < ActionController::API
  include ActionController::Cookies
  include ActionController::RequestForgeryProtection
  include Pundit
  protect_from_forgery with: :exception
  # TODO: confirm csrf is being checked
  before_action :set_csrf_cookie
  before_action :authenticate_user!

  # TODO: finish setting up Pundit
  # after_action :verify_authorized, except: :index
  # after_action :verify_policy_scoped, only: :index

  helper_method :current_user

  #
  # Rescue common errors
  #
  rescue_from ActiveRecord::RecordInvalid, with: :render_unprocessable_entity_response
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found_response
  rescue_from ApplicationError do |ex|
    response_handler(ex)
  end

  #
  # Render rescue responses
  #
  def render_unprocessable_entity_response(ex)
    render json: { errors: ex.record.errors }, status: :unprocessable_entity
  end

  def render_not_found_response(ex)
    render json: { error: ex.message }, status: :not_found
  end

  def response_handler(res)
    if res.is_a? StandardError
      error_handler(res)
    else
      success_handler(res)
    end
  end

  def error_handler(ex)
    code = ex.config[:http_code] || 500
    render status: code, json: { success: false, error: ex.message, code: ex.code }
  end

  def success_handler(ex)
    render status: 200, json: { success: true, data: ex }
  end

  #
  # Session helper methods
  #
  # https://medium.com/@ajayramesh/social-login-with-omniauth-and-rails-5-0-ad2bbd2a998e
  def authenticate_user!
    raise ApplicationError::AuthenticationFailure unless user_signed_in?
  end

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def user_signed_in?
    !!current_user
  end

  private

  def set_csrf_cookie
    cookies['_opencspm_token'] = {
      value: form_authenticity_token,
      domain: Rails.application.config.cookie_domain,
      secure: Rails.application.config.secure_csrf_token
    }
  end
end

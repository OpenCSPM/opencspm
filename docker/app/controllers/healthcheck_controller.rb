class HealthcheckController < ApplicationController
  skip_before_action :authenticate_user!
  skip_forgery_protection

  #
  # Respond to health checks
  #
  def index
    render plain: 'ok', status: :ok
  end
end

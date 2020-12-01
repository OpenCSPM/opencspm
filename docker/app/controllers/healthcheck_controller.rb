class HealthcheckController < ApplicationController
  skip_before_action :authenticate_user!
  skip_forgery_protection

  #
  # Respond to health checks
  #
  def index
    render plain: 'ok', status: :ok
  end

  #
  # Respond to smoke test status check
  #
  def show
    statuses = [
      Job.count,
      Resource.count,
      Issue.count,
      Control.count
    ]

    status = statuses.all? { |s| s > 0 }

    response_code = status ? :ok : :service_unavailable

    render plain: response_code.to_s, status: response_code
  end
end

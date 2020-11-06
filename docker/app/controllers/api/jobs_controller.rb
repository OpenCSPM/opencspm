class Api::JobsController < ApplicationController
  # GET /jobs
  def index
    @jobs = Job.order(id: :desc).limit(10)

    render json: @jobs
  end
end

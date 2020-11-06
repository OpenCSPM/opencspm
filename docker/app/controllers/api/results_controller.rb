class Api::ResultsController < ApplicationController
  # GET /results
  def index
    @issue_count = Profile.active.sum(:issue_count)

    render json: { issue_count: @issue_count }
  end
end

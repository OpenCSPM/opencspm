class Api::CampaignResultsController < ApplicationController
  before_action :set_campaign, only: %i[index]

  # GET /campaign/1/results
  def index
    render json: ResultsSerializer.new(@campaign.results)
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_campaign
    @campaign = Campaign.find_by_id!(params[:campaign_id])
  end
end

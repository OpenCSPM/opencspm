class Api::ControlsController < ApplicationController
  before_action :set_control, only: %i[show destroy]
  before_action :set_campaign, only: %i[destroy]

  # GET /controls
  def index
    @controls = Control.with_mapped_tags

    render json: ControlsSerializer.new(@controls)
  end

  # GET /controls/1
  def show
    # render json: @control
    render json: ControlSerializer.new(@control)
  end

  # DELETE /campaigns/1/controls/2
  def destroy
    @campaign.find(@control.id).destroy if @control
    render json: CampaignSerializer.new(@campaign)
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_control
    @control = Control.find_by_id!(params[:id])
  end

  def set_campaign
    @campaign = Campaign.find_by_id!(params[:campaign_id])
  end
end

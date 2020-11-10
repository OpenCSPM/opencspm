class Api::CampaignsController < ApplicationController
  before_action :set_campaign, only: %i[show update destroy]

  # GET /campaigns
  def index
    @campaigns = Campaign.all

    render json: CampaignsSerializer.new(@campaigns)
  end

  # GET /campaigns/1
  def show
    render json: CampaignSerializer.new(@campaign)
  end

  # POST /campaigns
  def create
    user = current_user

    @campaign = user.campaigns.new(campaign_params)

    # default params
    @campaign.name = 'New Campaign'
    @campaign.organization_id = user.organization.id

    render json: CampaignSerializer.new(@campaign), status: :created if @campaign.save!
  end

  # PATCH/PUT /campaigns/1
  def update
    render json: CampaignSerializer.new(@campaign) if @campaign.update!(campaign_params)
  end

  # DELETE /campaigns/1
  def destroy
    @campaign.destroy
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_campaign
    @campaign = Campaign.find_by_id!(params[:id])
  end

  # Only allow a trusted parameter "allow list" through.
  def campaign_params
    params.require(:campaign).permit(:name, :notes, filters: {})
  end
end

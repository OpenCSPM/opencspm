class CampaignSerializer
  include FastJsonapi::ObjectSerializer
  attributes :name, :filters, :controls

  attribute :controls do |campaign|
    CampaignControlsSerializer.new(campaign.controls)
  end
end

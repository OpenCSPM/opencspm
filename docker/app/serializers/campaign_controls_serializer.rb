class CampaignControlsSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :guid, :name, :title, :description, :platform, :impact, :status, :resources_failed, :resources_total

  attribute :tags do |control|
    control.tags.map(&:name)
  end
end

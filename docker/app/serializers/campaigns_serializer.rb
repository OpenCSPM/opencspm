class CampaignsSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :name, :filters, :control_count, :updated_at
end

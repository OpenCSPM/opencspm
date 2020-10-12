class ControlsSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :guid, :control_id, :title, :description, :platform, :impact, :status, :resources_failed, :resources_total

  attribute :tags do |control|
    control.tags.map(&:name)
  end
end

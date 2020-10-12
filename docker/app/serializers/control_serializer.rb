class ControlSerializer
  include FastJsonapi::ObjectSerializer
  attributes :resources, :tags

  attribute :tags do |control|
    control.tags.map(&:control_id)
  end
end

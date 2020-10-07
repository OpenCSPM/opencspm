class ControlSerializer
  include FastJsonapi::ObjectSerializer
  attributes :resources, :tags

  attribute :tags do |control|
    control.tags.map(&:name)
  end
end

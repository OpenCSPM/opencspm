class ControlSerializer
  include FastJsonapi::ObjectSerializer
  attributes :resources,
             :tags

  attribute :resources do |control|
    control.results.last.issues.includes(:resource).map { |issue| { status: issue.status, name: issue.resource.name } }
  end

  attribute :tags do |control|
    control.tags.map(&:name)
  end
end

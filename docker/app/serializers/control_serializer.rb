class ControlSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id,
             :guid,
             :control_pack,
             :control_id,
             :title,
             :description,
             :remediation,
             :validation,
             :refs,
             :impact,
             :status,
             :resources

  attribute :resources do |control|
    if control.results.empty?
      []
    else
      control.results.last.issues.includes(:resource).map { |issue| { status: issue.status, name: issue.resource.name } }
    end
  end

  attribute :tags do |control|
    control.taggings.includes(:tag).map { |t| { tag: t.tag.name, primary: t.primary } }
  end
end

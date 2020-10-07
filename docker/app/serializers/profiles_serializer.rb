class ProfilesSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :name, :author, :platform, :tags

  attribute :controls do |profile|
    # TODO: optionally include ALL tags, not just ANY tag
    Control.includes(:tags).where(tags: { name: profile.tags })
  end
end

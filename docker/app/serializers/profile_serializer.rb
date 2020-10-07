class ProfileSerializer
  include FastJsonapi::ObjectSerializer
  attributes :name, :status, :platform, :tag, :issue_count

  # TODO: move to join in ProfilesController
  attribute :controls do |profile|
    profile&.controls
  end
end

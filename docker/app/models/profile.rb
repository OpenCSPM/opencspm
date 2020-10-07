class Profile < ApplicationRecord
  has_many :jobs

  #
  # TODO: Read from local profile .yml files instead of db/seeds.rb
  #
  def sync_from_files
    # File read YAML load
  end
end

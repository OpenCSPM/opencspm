class Control < ApplicationRecord
  has_many :taggings, dependent: :destroy
  has_many :tags, through: :taggings
  has_many :results
  has_many :jobs, through: :results
  has_many :issues, through: :results
  has_many :resources, -> { distinct }, through: :results

  enum status: { failed: -1, unknown: 0, passed: 1 }

  #
  # Tags
  #
  def tag_list
    tags.join(', ')
  end

  #
  # Tags
  #
  def tag_list=(tags_string)
    tag_names = tags_string.split(',').collect { |s| s.strip.downcase }.uniq
    new_or_found_tags = tag_names.collect { |name| Tag.find_or_create_by(name: name) }
    self.tags = new_or_found_tags
  end
end

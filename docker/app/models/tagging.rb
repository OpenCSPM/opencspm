class Tagging < ApplicationRecord
  belongs_to :tag
  belongs_to :control

  scope :primary, -> { where(primary: true) }
end

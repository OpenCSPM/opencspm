class Result < ApplicationRecord
  belongs_to :job
  belongs_to :control
  has_many :issues, dependent: :destroy
  has_many :resources, through: :issues
end

# frozen_string_literal: true

class Tag < ApplicationRecord
  has_many :taggings
  has_many :controls, through: :taggings

  def to_s
    name
  end
end

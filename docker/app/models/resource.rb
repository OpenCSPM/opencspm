# frozen_string_literal: true

class Resource < ApplicationRecord
  has_many :issues
  has_many :results, through: :issues

  private

  #
  #  TODO: write this
  #
  def cleanup
    # destroy resources with no issues
  end
end

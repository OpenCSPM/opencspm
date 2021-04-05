# frozen_string_literal: true

class Issue < ApplicationRecord
  belongs_to :result
  belongs_to :resource

  enum status: { passed: 0, failed: 1 }
end

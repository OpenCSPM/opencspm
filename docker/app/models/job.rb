class Job < ApplicationRecord
  has_secure_token
  has_many :results

  enum status: { running: 0, complete: 1 }
end

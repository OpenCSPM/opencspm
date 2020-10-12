class Job < ApplicationRecord
  has_many :results

  enum status: {
    running: 0,
    complete: 1,
    failed: -1
  }
  enum kind: {
    run: 0,
    load: 1,
    analyze: 2,
    parse: 3,
    cleanup: 4
  }, _prefix: :job
end

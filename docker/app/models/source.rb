class Source < ApplicationRecord
  enum status: {
    disabled: 0,
    active: 1,
    scan_requested: 2,
    scanning: 3
  }

  def schedule_worker
    RunnerJob.perform_later if scan_requested?
  end
end

class Source < ApplicationRecord
  enum status: {
    disabled: 0,
    active: 1,
    scan_requested: 2,
    scanning: 3
  }

  def schedule_worker
    if scan_requested?
      scanning!
      LoaderJob.perform_later({ source_id: id })
    end
  end
end

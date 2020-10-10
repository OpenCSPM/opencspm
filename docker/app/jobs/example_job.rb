require 'pry'

class ExampleJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # Do something later
    logger.info "Job run"
  end
end

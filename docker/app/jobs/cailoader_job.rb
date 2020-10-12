# Add lib to the load path
$:.unshift(File.expand_path("lib", __dir__))
require 'config/config_loader'
require 'batch_importer'
require 'pry'

class CailoaderJob < ApplicationJob
  queue_as :default

  def perform(*args)
    logger.info "Job run started"
    job = Job.create(status: :running)

    config_file = "load_config/config.yaml"

    logger.info "Loading configuration"
    config = ConfigLoader.new(config_file).parsed_config

    logger.info "Loading data..."
    BatchImporter.new(config).import

    job.complete!
    logger.info "Job run ended"
  end
end

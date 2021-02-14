# frozen_string_literal: true

# Add lib to the load path
$:.unshift(File.expand_path('lib', __dir__))
require 'batch_importer'
require 'pry'

class LoaderJob < ApplicationJob
  queue_as :default
  CONFIG_FILE = 'load_config/config.yaml'

  TYPE = :load

  def perform(args)
    unless args.key?(:guid)
      logger.info 'Loader job not running without a GUID.'
      return nil
    end

    # shared GUID
    guid = args[:guid]
    logger.info "#{guid} Loader job started"

    # Track the job
    job = Job.create(status: :running, kind: TYPE, guid: guid)

    logger.info 'Loading data'

    begin
      BatchImporter.new(CONFIG_FILE).import
      job.complete!
      puts "Loader job finished - #{guid}"
    rescue StandardError => e
      job.failed!
      puts "Loader job failed - #{e.class} #{e.message} (#{e.backtrace[0]})"

      # re-raise for RunnerJob
      raise e
    end
  end
end

# Add lib to the load path
$:.unshift(File.expand_path('lib', __dir__))
require 'batch_importer'
require 'pry'

class LoaderJob < ApplicationJob
  queue_as :default

  TYPE = :load

  def perform(args)
    unless args.has_key?(:guid)
      logger.info 'Loader job not running without a GUID.'
      return nil
    end

    # shared GUID
    guid = args[:guid]
    logger.info "#{guid} Loader job started"

    # Track the job
    job = Job.create(status: :running, kind: TYPE, guid: guid)

    logger.info 'Loading data'
    BatchImporter.new("load_config/config.yaml").import

    job.complete!
    logger.info "#{guid} Loader job finished"
  end
end

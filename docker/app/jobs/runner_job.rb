# frozen_string_literal: true

#
# Wrapper for LoaderJob and AnalysisJob
#
class RunnerJob < ApplicationJob
  queue_as :default
  # not supported by sidekiq-cron
  # sidekiq_options retry: 5

  RESULTS_FILE = '/tmp/results'
  TYPE = :run

  def perform
    # Don't run again if a Job is still running
    if Job.running.find_by(kind: TYPE)
      logger.info('Runner job already running, not starting again...')
      return
    end

    # Shared GUID
    guid = Digest::UUID.uuid_v5(Digest::UUID::OID_NAMESPACE, Time.now.utc.to_s)

    logger.info("#{guid} Runner job started")

    # Track the job
    job = Job.create(status: :running, kind: TYPE, guid: guid)

    #
    # Loader job
    #
    unless LoaderJob.new.perform(guid: guid)
      job.failed!
      return
    end

    #
    # Analysis job
    #
    unless AnalysisJob.new.perform(guid: guid)
      job.failed!
      return
    end

    #
    # Parse results
    #
    unless File.file?(RESULTS_FILE)
      job.failed!
      return
    end

    # TEMP DEBUG
    # job.complete!
    # return

    results = JSON.parse(File.read(RESULTS_FILE), object_class: OpenStruct)

    results.each do |result|
      control = Control.find_by(control_pack: result.control_pack, control_id: result.control_id)

      next unless control

      resources_failed = result&.resources&.filter { |r| r.status == 'failed' }&.length.to_i
      resources_total = result&.resources&.length

      result_hash = {
        status: resources_failed.positive? ? -1 : 1,
        resources_failed: resources_failed,
        resources_total: resources_total
      }

      control.update(result_hash)

      # dummy timestamp
      timestamp = 0.days.ago.utc.to_s

      new_result = Result.create({ job: job, control: control, data: result_hash, observed_at: timestamp })

      next unless new_result

      #
      # Find or create nested resources for the control
      #
      result&.resources&.each do |r|
        resource = Resource.find_or_create_by({ name: r.name })
        new_result.issues.create(resource: resource, status: r.status)
      end

      # Track the job
      job.complete!
    end

    logger.info("#{guid} Runner job finished")
  end
end

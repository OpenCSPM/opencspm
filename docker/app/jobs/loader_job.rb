class LoaderJob < ApplicationJob
  queue_as :default
  # not supported by sidekiq-cron
  # sidekiq_options retry: 5

  # 40% fail rate
  STATUSES = [-1, -1, -1, -1, -1, -1, 1, 1, 1, 1].freeze

  def perform(*args)
    logger.debug("job for loader #{args} starting...")

    # Sidekiq Cron passes args as an Array
    args = args.map { |x| x.symbolize_keys } if args.is_a?(Array)

    args.each do |arg|
      next unless arg[:source_id]

      source = Source.find(arg[:source_id])

      next unless source

      job = Job.create(status: :running)

      controls = Control.all

      # dummy timestamp
      timestamp = arg[:timestamp] || 0.days.ago.utc.to_s

      controls.each do |control|
        resources = rand(1..2500)

        result = {
          status: STATUSES.sample,
          resources_failed: (resources * 0.35).to_i,
          resources_total: resources
        }

        control.update(result)

        Result.create({ job: job, control: control, data: result, observed_at: timestamp })
      end

      source.active!
      job.complete!
    end

    logger.debug("job for loader #{args} done.")
  end
end

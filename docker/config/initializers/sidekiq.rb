# frozen_string_literal: true

# force log level down to :info
# Sidekiq::Logging.logger.level = Logger::INFO if Rails.env.development?

# https://github.com/ondrejbartas/sidekiq-cron/issues/249#issuecomment-577492567
# sidekiq-cron
if Sidekiq.server?
  Rails.application.config.after_initialize do
    h = YAML.load_file(Rails.root.join('config', 'scheduled-jobs.yml'))
    Sidekiq::Cron::Job.load_from_hash(h)
  end
end

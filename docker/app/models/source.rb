# frozen_string_literal: true

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

  def refresh
    # read config file, find or create a source for each source listed
    config_sources = JSON.parse(YAML.load_file(LoaderJob::CONFIG_FILE).to_json, object_class: OpenStruct)

    return unless config_sources&.local_dirs&.length&.positive?

    config_sources.local_dirs.each do |dir|
      puts "Config file local dir source=#{dir}"
      source = Source.find_or_create_by(name: dir)
      source.active!
    end

    # loop through all existing sources, disable if not in config file
    Source.all.each do |source|
      puts "Config file system source=#{source.name} status=#{source.status}"
      source.disabled! unless config_sources.local_dirs.include?(source.name)
    end
  end
end

# frozen-string-literal: true

require 'config/config_loader'
require 'fetcher/file_fetcher'
require 'loader/file_loader'
require 'redis'

# Handles the batch import process by loading the config,
# fetching the files, and dispatching them to the loader
class BatchImporter
  attr_accessor :load_config

  def initialize(config_file)
    puts "Loading config file: #{config_file}"
    @load_config = ConfigLoader.new(config_file).loaded_config
  end

  # Fetch the remote bucket and local_dir files to a local
  # temp directory, and send the db connection info and an
  # array of files to the asset loader
  # Save redis contents to disk when done
  def import
    puts "Fetching files from remote buckets and local directories"
    files_to_load = FileFetcher.new(@load_config).fetch
    db_options = get_db_options(@load_config)
    FileLoader.new(db_options, files_to_load)
    Redis.new(db_options.to_h).call("save")
  end

  private

  # Return a default db conn config or what is configured
  # in the load_config under "db"
  def get_db_options(load_config)
    unless load_config.respond_to?(:db)
      db_hash = { 'url' => 'redis://localhost:6379' }
      return OpenStruct.new(db_hash)
    end

    load_config.delete_field('db')
  end
end

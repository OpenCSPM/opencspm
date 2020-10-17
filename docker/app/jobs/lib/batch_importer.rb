# frozen-string-literal: true

require 'config/config_loader'
require 'fetcher/file_fetcher'
require 'loader/file_loader'

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
  def import
    puts "Fetching files from remote buckets and local directories"
    files_to_load = FileFetcher.new(@load_config).fetch
    FileLoader.new(get_db_config(@load_config), files_to_load)
  end

  private

  # Return a default db conn config or what is configured
  # in the load_config under "db"
  def get_db_config(load_config)
    unless load_config.respond_to?(:db)
      db_hash = { 'url' => 'redis://localhost:6379' }
      return OpenStruct.new(db_hash)
    end

    load_config.delete_field('db')
  end
end

# frozen-string-literal: true

require 'pry'

# Fetches files from buckets to a local dir
class FileFetcher
  attr_accessor :locations_to_fetch

  def initialize(locations_to_fetch)
    @locations_to_fetch = locations_to_fetch
    @remote_buckets = @locations_to_fetch.delete_field('buckets') if @locations_to_fetch.respond_to?(:buckets)
    @local_dirs = @locations_to_fetch.delete_field('local_dirs') if @locations_to_fetch.respond_to?(:local_dirs)
    @load_dir = File.expand_path('load_dir', Dir.pwd)
  end

  # Grabs from remote buckets to load_dir
  # Grabs from local dirs to load_dir
  # Returns an array of json files in load_dir
  def fetch
    pull_from_remote_buckets(@remote_buckets)
    pull_from_local_dirs(@local_dirs)
    load_dir_json_files
  end

  private

  # Pull buckets to load_dir
  def pull_from_remote_buckets(buckets)
    return if buckets.nil?
    # TODO: Call bucket loader
  end

  # Pull local_dirs to load_dir
  def pull_from_local_dirs(local_dirs)
    return if local_dirs.nil?
    # TODO: Call local loader
  end

  # Return list of files from local dir
  def load_dir_json_files
    Dir["#{@load_dir}/*.json"]
  end
end

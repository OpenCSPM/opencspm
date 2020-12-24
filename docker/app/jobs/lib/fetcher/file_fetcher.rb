# frozen-string-literal: true

require 'fetcher/types/bucket_fetcher'
require 'fetcher/types/local_fetcher'

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
    clean_load_dir
    pull_from_remote_buckets(@remote_buckets)
    pull_from_local_dirs(@local_dirs)
    load_dir_json_files
  end

  private

  # Clean up load dir where this job will fetch new files
  # from all locations (buckets and local fs dirs)
  # and place them in to be loaded/parsed
  def clean_load_dir
    puts "Cleaning #{@load_dir}"
    FileUtils.rm_rf(Dir.glob("#{@load_dir}/*.json"))
  end

  # Pull buckets to load_dir
  def pull_from_remote_buckets(buckets)
    return if buckets.nil?
    BucketFetcher.new(buckets, @load_dir).fetch
  end

  # Pull local_dirs to load_dir
  def pull_from_local_dirs(local_dirs)
    return if local_dirs.nil?
    LocalFetcher.new(local_dirs, @load_dir).fetch
  end

  # Return list of files from local dir
  def load_dir_json_files
    Dir["#{@load_dir}/combined_for_load.json"]
  end
end

# frozen-string-literal: true

require 'google/cloud/storage'
require 'logger'
require 'tempfile'

class BucketFetcher
  def initialize(bucket, load_dir)
    @buckets = bucket
    @load_dir = load_dir
    set_log_level
    @gcs_client =  Google::Cloud::Storage.new
  end

  def fetch
    @buckets.each do |bucket_name|
      bucket = fetch_bucket(bucket_name)
      manifest_files = manifest_files(bucket)
      loop_over_manifests(bucket, manifest_files)
    end
  end

  private

  def loop_over_manifests(bucket, manifest_files)
    manifest_files.each do |manifest|
      prefix_dir = File.dirname(manifest)
      manifest_contents_file = bucket.file(manifest).download
      manifest_contents_file.rewind
      latest_files = manifest_contents_file.read.split("\n").map{ |f| f = "#{prefix_dir}/#{f}" }
      fetch_files(bucket, latest_files)
    end
  end

  def fetch_files(bucket, latest_files)
    latest_files.each do |cai_file|
       cai_file = cai_file.chomp
       file = bucket.file cai_file
       dest_file_path = "#{@load_dir}/combined_for_load.json"
       puts "Appending #{bucket.name}/#{cai_file} to #{dest_file_path}"
       downloaded = file.download
       downloaded.rewind
       file_data = downloaded.read
       File.write(dest_file_path, file_data, mode: "ab")
    end
  end

  def fetch_bucket(bucket_name)
    @gcs_client.bucket strip_gs_slash(bucket_name)
  end
  
  def manifest_files(bucket)
    manifests = []
    bucket.files.each do |file|
      manifests << file.name if file.name.match /manifest.txt$/
    end
    manifests
  end

  def strip_gs_slash(bucket_name)
    bucket_name.gsub(%r{^gs://}, '')
  end

  def set_log_level
    my_logger = Logger.new $stderr
    my_logger.level = Logger::WARN
    
    # Set the Google API Client logger
    Google::Apis.logger = my_logger
  end
end

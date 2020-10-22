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
       dest_file_name = randomize_file_name(File.basename(cai_file))
       puts "Downloading #{bucket.name}/#{cai_file} to #{@load_dir}/#{dest_file_name}"
       file.download "#{@load_dir}/#{dest_file_name}"
    end
  end

  def randomize_file_name(file_name)
    # tmp-asdf23fwhj-myfilename.json
    "tmp-#{generate_code(8)}-#{file_name.chomp}"
  end

  def generate_code(number)
    charset = Array('A'..'Z') + Array('a'..'z')
    Array.new(number) { charset.sample }.join
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

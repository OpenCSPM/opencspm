require 'tempfile'
require "google/cloud/asset"
require "google/cloud/storage"

def export_gcp_cai
  parent_path = ENV['CAI_PARENT_PATH']
  bucket_name = ENV['GCS_BUCKET_NAME']
  bucket_folder = ENV['GCS_BUCKET_FOLDER'] || "cai"
  bucket_path = "gs://#{bucket_name}/#{bucket_folder}"
  
  asset_service = Google::Cloud::Asset.asset_service
  
  manifest_data = []
  current_utc = Time.now.to_i
  %w{ RESOURCE IAM_POLICY ORG_POLICY ACCESS_POLICY }.each do |ctype|
    export_file_name = "#{current_utc}-#{ctype.downcase}.json"
    output_config = { gcs_destination: { uri: "#{bucket_path}/#{export_file_name}" } }
   
    operation = asset_service.export_assets( parent: parent_path, content_type: ctype, output_config: output_config) do |op|
      # Handle the error.
      logger.error "ERROR: #{op.results.message}" if op.error?
      raise op.results.message if op.error?
    end
    
    operation.wait_until_done!
    response = operation.response
    logger.info "Exported assets to: #{response.output_config.gcs_destination.uri}"
    manifest_data << export_file_name
  end
  write_manifest(bucket_name, bucket_folder, manifest_data)
end

def write_manifest(bucket_name, bucket_folder, manifest_data)
  storage = Google::Cloud::Storage.new
  bucket = storage.bucket(bucket_name)

  IO.write("/tmp/manifest", manifest_data.join("\n"))
  uploaded_manifest = bucket.create_file("/tmp/manifest", "#{bucket_folder}/manifest.txt")
  logger.info "Uploaded #{uploaded_manifest.name}"
end

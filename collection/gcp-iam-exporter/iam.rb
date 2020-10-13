require 'tempfile'
require 'google/cloud/storage'
require 'open-uri'

def export_iam_cai
  bucket_name = ENV['GCS_BUCKET_NAME']
  bucket_folder = ENV['GCS_BUCKET_FOLDER'] || "iam"
  bucket_path = "gs://#{bucket_name}/#{bucket_folder}"
  iam_cai_uri = ENV['IAM_CAI_URI'] || "https://github.com/darkbitio/gcp-iam-role-permissions/raw/master/gcp_roles_cai.json"
  
  current_utc = Time.now.to_i
  export_file_name = "#{current_utc}-full-iam-export.json"

  iam_cai_data = URI.parse(iam_cai_uri).read

  # Write the file locally
  tmp_file_path = "/tmp/iam-roles.json"
  IO.write(tmp_file_path, iam_cai_data)

  # Write the iam roles file to the bucket
  write_iam_file(bucket_name, bucket_folder, tmp_file_path, export_file_name)

  # Write the manifest to the bucket
  manifest_data = []
  manifest_data << export_file_name
  write_manifest(bucket_name, bucket_folder, manifest_data)
end

def write_iam_file(bucket_name, bucket_folder, tmp_file, export_file_name)
  storage = Google::Cloud::Storage.new
  bucket = storage.bucket(bucket_name)

  uploaded_manifest = bucket.create_file(tmp_file, "#{bucket_folder}/#{export_file_name}")
  logger.info "Uploaded #{uploaded_manifest.name}"
end

def write_manifest(bucket_name, bucket_folder, manifest_data)
  storage = Google::Cloud::Storage.new
  bucket = storage.bucket(bucket_name)

  IO.write("/tmp/manifest", manifest_data.join("\n"))
  uploaded_manifest = bucket.create_file("/tmp/manifest", "#{bucket_folder}/manifest.txt")
  logger.info "Uploaded #{uploaded_manifest.name}"
end

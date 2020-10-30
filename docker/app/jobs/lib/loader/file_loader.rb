# frozen-string-literal: true

require 'validator/cai'
require 'loader/asset/asset_router'
require 'redisgraph'
require 'db/redisgraph'
require 'loader/misc/post_loader'

# Given an array of files, for each file, for each
# line, validates the line as jsonlines, determines
# asset type, and dispatches to the proper loader
class FileLoader
  include Validator::CAI
  include GraphDB::DB

  attr_accessor :db_config, :files_to_load

  def initialize(db_config, files_to_load)
    @import_id = Time.now.utc.to_i
    @db_config = db_config
    @db = db_connection(db_config)
    @files_to_load = files_to_load
    load
  end

  def load
    loop_over_files(@files_to_load)
    PostLoader.new(@db, @import_id)
  end

  private

  def loop_over_files(files)
    files.each do |file_name|
      loop_over_asset_lines(file_name)
    end
  end

  # Validate each line in the file as valid CAI
  # format.  Send to asset router
  def loop_over_asset_lines(file_name)
    puts "Loading #{file_name}"
    IO.foreach(file_name) do |line|
      asset_json = parse_json_line(line)

      # TEMP DEBUG - AWS only
      if (%w[account service region resource] - asset_json.keys).empty?
        AssetRouter.new(asset_json, @import_id, @db)
      end

      # skip validation for AWS Recon JSON
      # if (%w[account service region resource] - asset_json.keys).empty? || validate_schema(asset_json)
      #   AssetRouter.new(asset_json, @import_id, @db)
      # end
    end
    puts ''
    puts "Done loading #{file_name}"
  end
end

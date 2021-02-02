# frozen-string-literal: true

require 'loader/asset/asset_router'
require 'redisgraph'
require 'db/redisgraph'
require 'loader/misc/post_loader'
require 'fast_jsonparser'
require 'parallel'

# Given an array of files, for each file, for each
# line, validates the line as jsonlines, determines
# asset type, and dispatches to the proper loader
class FileLoader
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
    batch_size = 50_000
    File.open(file_name) do |file|
      file.each_slice(batch_size) do |lines|
        Parallel.each(lines, in_processes: 8) do |line|
          asset_json = FastJsonparser.parse(line, symbolize_keys: false)
          if (%w[account service region resource] - asset_json.keys).empty? || validate_schema(asset_json)
            AssetRouter.new(asset_json, @import_id, @db)
          end
        end
      end
    end
    puts ''
    puts "Done loading #{file_name}"
  end

  def validate_schema(asset_json)
    return true if asset_json.dig('name') && asset_json.dig('asset_type')

    false
  end
end

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

  # Batch load file, send each line to asset router
  def loop_over_asset_lines(file_name)
    line_count = 0
    puts "Loading #{file_name}"
    batch_size = 25000
    File.open(file_name) do |file|
      file.each_slice(batch_size) do |lines|
        line_count += lines.length
        Parallel.each(lines, in_processes: 8) do |line|
          begin
            asset_json = FastJsonparser.parse(line, symbolize_keys: false)
            AssetRouter.new(asset_json, @import_id, @db)
            line_count += 1
          rescue FastJsonparser::ParseError => e
            puts "[file_loader] Error: JSON can't be parsed. Ensure you are loading NDJSON files."
            raise e
          end
        end
      end
    end

    puts "\n\nDone loading #{file_name}. (#{line_count} lines)"
  end
end

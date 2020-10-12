require 'addressable'
require 'fetcher/datatype_fetcher'
require 'pry'
Dir["./app/jobs/lib/fetcher/datatype_fetchers/*fetcher.rb"].each {|file| require file }
require 'loader/cai_loader'

class BatchImporter

  attr_accessor :account_name
  attr_reader :import_id, :full_config, :db_config

  def initialize(config)
    @full_config = config
    @db_config = full_config.db.to_h
    @import_id = Time.now.to_i
  end

  def import
    loop_over_config
    enrich_data
    install_indexes
    cleanup_data
  end

  private

  def loop_over_config
    full_config.accounts.each do |account|
      @account_name = "#{account.platform.upcase}_#{account.id}"
      parse_account(account)
    end
  end

  def parse_account(account)
    account.datasources.each { |datasource| parse_datasource(datasource) }
  end

  def parse_datasource(datasource)
    datasource.datatypes.each do |datatype|
      loader_config = get_loader_config(datasource, datatype)
      fetcher_name = "#{datasource.storage.capitalize}Fetcher"
      valid_cai_files = Object.const_get(fetcher_name).new(loader_config).fetch_files
      load_cai_files(loader_config[:format], valid_cai_files)  
    end
  end

  def load_cai_files(file_type, valid_cai_files)
    valid_cai_files.each do |cai_file|
      CAILoader.new(file_type, cai_file, import_id, db_config, account_name).load_cai_file
    end
  end

  def get_loader_config(datasource, datatype)
    { :account_name => account_name,
      :import_id => import_id,
      :path => clean_path(datasource.path, datatype.path_prefix),
      :format => datatype.format.downcase
    }
  end

  def clean_path(path, prefix)
    Addressable::URI.join(path, prefix).to_s
  end

  def enrich_data
    puts "enrichment processes"
    CAILoader.new('dummy', 'dummy', import_id, db_config, account_name).enrich_data
  end

  def install_indexes
    puts "install indexes"
    CAILoader.new('dummy', 'dummy', import_id, db_config, account_name).install_indexes
  end

  def cleanup_data
    puts "cleanup old data"
    CAILoader.new('dummy', 'dummy', import_id, db_config, account_name).cleanup_data
  end
end


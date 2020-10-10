require 'validator/cai'
#require 'redisgraph'
#require 'db/redisgraph'

class DataTypeFetcher

  include Validator::CAI
  #include GraphDB::DB

  attr_reader :fetcher_config#, :db_config, :dbconn

  def initialize(loader_config)
    @fetcher_config = loader_config
    #@db_config = db_config
    #@dbconn = db_connection
  end

  def fetch_files
    raise NotImplementedError
  end

  #private

  #def db_connection
  #  self.db(fetcher_config[:account_name], db_config)
  #end
end

require 'redisgraph'

def graphdb
  account_name = 'GCP_1234567890'
  db_config = { :url => 'redis://redis:6379' }
  db ||= RedisGraph.new(account_name, db_config)
end

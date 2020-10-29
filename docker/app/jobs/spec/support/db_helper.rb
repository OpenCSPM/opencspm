require 'redisgraph'

def graphdb
  account_name = 'opencspm'
  db_config = { url: 'redis://redis:6379' }
  db ||= RedisGraph.new(account_name, db_config)
end

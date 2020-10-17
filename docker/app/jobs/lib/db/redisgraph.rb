# frozen-string-literal: true

# Returns a Graph DB connection
module GraphDB
  # For RedisGraph
  module DB
    def db_connection(db_config)
      RedisGraph.new('opencspm', db_config.to_h)
    end
  end
end

module GraphDB
  module DB
    def db_conn(account_name, config)
      RedisGraph.new(account_name, db_config)
    end
  end
end

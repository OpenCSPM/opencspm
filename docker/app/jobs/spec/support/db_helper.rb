require 'redisgraph'

#
# Monkeypatch RedisGraph QueryResult to return an array of Structs
# instead of an array of Arrays.
#
# https://github.com/RedisGraph/redisgraph-rb/blob/master/lib/redisgraph/query_result.rb
#
class QueryResult
  def mapped_results
    if columns && columns.length > 0
      resultset.map do |result|
        hash = {}

        columns.each_with_index do |col, idx|
          hash[col] = result[idx]
        end

        OpenStruct.new(hash)
      end
    else
      resultset
    end
  end
end

def graphdb
  account_name = 'opencspm'
  db_config = { url: 'redis://redis:6379' }
  db ||= RedisGraph.new(account_name, db_config)
end

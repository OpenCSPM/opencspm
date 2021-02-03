# frozen_string_literal: true

#
# Load Transfer assets into RedisGraph
#
# Each method returns an array of Cypher queries
#
class AWSLoader::Transfer < GraphDbLoader
  def server
    node = 'AWS_TRANSFER_SERVER'
    q = []

    # server node
    q.push(_upsert({ node: node, id: @name }))
  end
end

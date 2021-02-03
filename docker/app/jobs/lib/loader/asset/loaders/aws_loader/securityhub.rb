# frozen_string_literal: true

#
# Load SecurityHub assets into RedisGraph
#
# Each method returns an array of Cypher queries
#
class AWSLoader::SecurityHub < GraphDbLoader
  def hub
    node = 'AWS_SECURITYHUB_HUB'
    q = []

    # hub node
    q.push(_upsert({ node: node, id: @name }))
  end
end

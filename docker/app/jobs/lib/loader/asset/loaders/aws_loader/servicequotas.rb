# frozen_string_literal: true

#
# Load ServiceQuota assets into RedisGraph
#
# Each method returns an array of Cypher queries
#
class AWSLoader::ServiceQuotas < GraphDbLoader
  def quota
    node = 'AWS_SERVICE_QUOTA'
    q = []

    # quota node
    q.push(_upsert({ node: node, id: @name }))
  end
end

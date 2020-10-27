#
# Load ElastiCache assets into RedisGraph
#
# Each method returns an array of Cypher queries
#
class AWSLoader::ElastiCache < AwsGraphDbLoader
  def cluster
    node = 'AWS_ELASTICACHE_CLUSTER'
    q = []

    # cluster node
    q.push(_upsert({ node: node, id: @name }))
  end
end

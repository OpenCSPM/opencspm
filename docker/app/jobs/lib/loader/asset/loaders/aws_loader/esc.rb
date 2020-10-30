#
# Load ECS assets into RedisGraph
#
# Each method returns an array of Cypher queries
#
class AWSLoader::ECS < GraphDbLoader
  def cluster
    node = 'AWS_ECS_CLUSTER'
    q = []

    # cluster node
    q.push(_upsert({ node: node, id: @name }))

    q
  end
end

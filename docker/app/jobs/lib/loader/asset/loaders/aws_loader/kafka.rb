#
# Load Kafka assets into RedisGraph
#
# Each method returns an array of Cypher queries
#
class AWSLoader::Kafka < GraphDbLoader
  def cluster
    node = 'AWS_KAFKA_CLUSTER'
    q = []

    # cluster node
    q.push(_upsert({ node: node, id: @name }))

    q
  end
end

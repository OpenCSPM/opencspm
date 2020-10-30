#
# Load SQS assets into RedisGraph
#
# Each method returns an array of Cypher queries
#
class AWSLoader::SQS < GraphDbLoader
  def queue
    node = 'AWS_SQS_QUEUE'
    q = []

    # queue node
    q.push(_upsert({ node: node, id: @name }))

    q
  end
end

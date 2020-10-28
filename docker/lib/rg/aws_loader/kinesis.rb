#
# Load Kinesis assets into RedisGraph
#
# Each method returns an array of Cypher queries
#
class AWSLoader::Kinesis < AwsGraphDbLoader
  def stream
    node = 'AWS_KINESIS_STREAM'
    q = []

    # stream node
    q.push(_upsert({ node: node, id: @name }))

    q
  end
end

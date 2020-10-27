#
# Load SNS assets into RedisGraph
#
# Each method returns an array of Cypher queries
#
class AWSLoader::SNS < AwsGraphDbLoader
  def topic
    node = 'AWS_SNS_TOPIC'
    q = []

    # topic node
    q.push(_upsert({ node: node, id: @name }))

    # TODO: map AWS_SNS_SUBSCRIPTIONs
    q
  end
end

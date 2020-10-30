#
# Load CloudFormation assets into RedisGraph
#
# Each method returns an array of Cypher queries
#
class AWSLoader::CloudFormation < GraphDbLoader
  def stack
    node = 'AWS_CLOUDFORMATION_STACK'
    q = []

    # stack node
    q.push(_upsert({ node: node, id: @name }))

    # TODO: map parameters
    # TODO: map outputs
  end
end

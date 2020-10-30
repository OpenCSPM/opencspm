#
# Load SSM assets into RedisGraph
#
# Each method returns an array of Cypher queries
#
class AWSLoader::SSM < GraphDbLoader
  def instance
    node = 'AWS_SSM_INSTANCE'
    q = []

    # instance node
    q.push(_upsert({ node: node, id: @name }))

    q
  end

  def parameter
    node = 'AWS_SSM_PARAMETER'
    q = []

    # parameter node
    q.push(_upsert({ node: node, id: @name }))

    q
  end
end

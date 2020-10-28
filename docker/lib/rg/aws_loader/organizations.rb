#
# Load Organizations assets into RedisGraph
#
# Each method returns an array of Cypher queries
#
class AWSLoader::Organizations < AwsGraphDbLoader
  def organization
    node = 'AWS_ORGANIZATION'
    q = []

    # organization node
    q.push(_upsert({ node: node, id: @name }))

    q
  end

  def handshake
    node = 'AWS_ORGANIZATION_HANDSHAKE'
    q = []

    # handshake node
    q.push(_upsert({ node: node, id: @name }))

    q
  end
end

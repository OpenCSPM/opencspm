#
# Load APIGateway assets into RedisGraph
#
# Each method returns an array of Cypher queries
#
class AWSLoader::APIGateway < GraphDbLoader
  def api
    node = 'AWS_API_GATEWAY'
    q = []

    # api node
    q.push(_upsert({ node: node, id: @name }))

    # TODO: link to AWS_CERTIFICATE
    # TODO: link to AWS_API_GATEWAY_STAGE
  end

  def domain
    node = 'AWS_API_GATEWAY_DOMAIN'
    q = []

    # domain node
    q.push(_upsert({ node: node, id: @name }))

    # TODO: link to AWS_API_GATEWAY
    # TODO: link to AWS_CERTIFICATE
  end
end

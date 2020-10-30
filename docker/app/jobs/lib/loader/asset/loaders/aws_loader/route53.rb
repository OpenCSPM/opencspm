#
# Load Route53 assets into RedisGraph
#
# Each method returns an array of Cypher queries
#
class AWSLoader::Route53 < GraphDbLoader
  def zone
    node = 'AWS_ROUTE53_ZONE'
    q = []

    # zone node
    q.push(_upsert({ node: node, id: @name }))

    q
  end
end

#
# Load KMS assets into RedisGraph
#
# Each method returns an array of Cypher queries
#
class AWSLoader::KMS < GraphDbLoader
  def key
    node = 'AWS_KMS_KEY'
    q = []

    # key node
    q.push(_upsert({ node: node, id: @name }))

    # TODO: filter out policy field

    q
  end
end

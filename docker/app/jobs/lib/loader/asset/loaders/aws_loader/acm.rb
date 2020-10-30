#
# Load ACM assets into RedisGraph
#
# Each method returns an array of Cypher queries
#
class AWSLoader::ACM < GraphDbLoader
  def certificate
    node = 'AWS_CERTIFICATE'
    q = []

    # certificate node
    q.push(_upsert({ node: node, id: @name }))

    # certificate details
    if @data.details
      opts = {
        node: node,
        id: @name,
        data: @data.details
      }

      q.push(_append(opts))
    end

    q
  end
end

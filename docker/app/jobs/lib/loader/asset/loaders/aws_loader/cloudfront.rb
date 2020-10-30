#
# Load CloudFront assets into RedisGraph
#
# Each method returns an array of Cypher queries
#
class AWSLoader::CloudFront < GraphDbLoader
  def distribution
    node = 'AWS_CLOUDFRONT_DISTRIBUTION'
    q = []

    # distribution node
    q.push(_upsert({ node: node, id: @name }))

    # distribution details
    if @data.details
      opts = {
        node: node,
        id: @name,
        data: @data.details
      }

      q.push(_append(opts))
    end

    # TODO: map origins
    # TODO: map aliases
    # TODO: map cache behaviors
    # TODO: map certificates

    q
  end
end

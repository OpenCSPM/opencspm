# frozen_string_literal: true

#
# Load CloudTrail assets into RedisGraph
#
# Each method returns an array of Cypher queries
#
class AWSLoader::CloudTrail < GraphDbLoader
  def cloud_trail
    node = 'AWS_CLOUDTRAIL_TRAIL'

    q = []

    # trail node
    q.push(_upsert({ node: node, id: @name }))

    # trail status
    if @data.status
      opts = {
        node: node,
        id: @name,
        data: @data.status
      }

      q.push(_append(opts))
    end

    q
  end
end

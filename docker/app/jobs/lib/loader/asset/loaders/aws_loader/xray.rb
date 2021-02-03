# frozen_string_literal: true

#
# Load XRay assets into RedisGraph
#
# Each method returns an array of Cypher queries
#
class AWSLoader::XRay < GraphDbLoader
  def config
    node = 'AWS_XRAY_CONFIG'
    q = []

    # block_public_access_configuration node
    q.push(_upsert({ node: node, id: @name }))
  end
end

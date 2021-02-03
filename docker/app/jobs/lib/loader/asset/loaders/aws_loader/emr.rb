# frozen_string_literal: true

#
# Load EMR assets into RedisGraph
#
# Each method returns an array of Cypher queries
#
class AWSLoader::EMR < GraphDbLoader
  def configuration
    node = 'AWS_EMR_CONFIGURATION'
    q = []

    # block_public_access_configuration node
    q.push(_upsert({ node: node, id: @name }))
  end
end

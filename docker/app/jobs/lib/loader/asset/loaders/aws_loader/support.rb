# frozen_string_literal: true

#
# Load Support assets into RedisGraph
#
# Each method returns an array of Cypher queries
#
class AWSLoader::Support < GraphDbLoader
  def trusted_advisor_check
    node = 'AWS_TRUSTED_ADVISOR_CHECK'
    q = []

    # trusted_advisor_check node
    q.push(_upsert({ node: node, id: @name }))

    q
  end
end

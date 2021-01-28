# frozen_string_literal: true

#
# Load AccessAnalyzer assets into RedisGraph
#
# Each method returns an array of Cypher queries
#
class AWSLoader::AccessAnalyzer < GraphDbLoader
  def analyzer
    node = 'AWS_ACCESS_ANALYZER'
    q = []

    # analyzer node
    q.push(_upsert({ node: node, id: @name }))
  end
end

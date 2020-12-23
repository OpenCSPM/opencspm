# frozen_string_literal: true

#
# Load DynamoDB assets into RedisGraph
#
# Each method returns an array of Cypher queries
#
class AWSLoader::DynamoDB < GraphDbLoader
  def table
    node = 'AWS_DYNAMODB_TABLE'
    q = []

    # table node
    q.push(_upsert({ node: node, id: @name }))

    q
  end
end

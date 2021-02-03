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

    # encryption attributes
    q.push(_append({ node: node, id: @name, data: {
                     sse_status: @data&.sse_description&.status || 'none',
                     sse_type: @data&.sse_description&.sse_type || 'none'
                   } }))

    q
  end

  def limits
    node = 'AWS_DYNAMODB_LIMITS'
    q = []

    # limits node
    q.push(_upsert({ node: node, id: @name }))
  end
end

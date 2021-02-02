# frozen_string_literal: true

#
# Load SES assets into RedisGraph
#
# Each method returns an array of Cypher queries
#
class AWSLoader::SES < GraphDbLoader
  def identity
    node = 'AWS_SES_IDENTITY'
    q = []

    # identity node
    q.push(_upsert({ node: node, id: @name }))

    # dkim attributes
    q.push(_append({ node: node, id: @name, data: {
                     dkim_enabled: @data&.dkim_attributes&.dkim_enabled || false,
                     dkim_verification_status: @data&.dkim_attributes&.dkim_verification_status
                   } }))
    q
  end
end

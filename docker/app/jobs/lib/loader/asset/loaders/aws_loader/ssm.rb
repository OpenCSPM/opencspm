# frozen_string_literal: true

#
# Load SSM assets into RedisGraph
#
# Each method returns an array of Cypher queries
#
class AWSLoader::SSM < GraphDbLoader
  def instance
    node = 'AWS_SSM_INSTANCE'
    q = []

    # instance node
    q.push(_upsert({ node: node, id: @name }))

    # instance -> ssm_instance
    opts = {
      from_node: 'AWS_E2_INSTANCE',
      from_name: @data.instance_id,
      to_node: node,
      to_name: @name,
      relationship: 'HAS_SSM_AGENT',
      relationship_attributes: {
        association_status: @data.association_status,
        ping_status: @data.ping_status
      },
      headless: true
    }

    q.push(_link(opts))

    q
  end

  def parameter
    node = 'AWS_SSM_PARAMETER'
    q = []

    # parameter node
    q.push(_upsert({ node: node, id: @name }))

    q
  end
end

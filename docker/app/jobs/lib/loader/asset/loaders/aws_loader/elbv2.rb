# frozen_string_literal: true

#
# Load ElasticLoadBalancingV2 assets into RedisGraph
#
# Each method returns an array of Cypher queries
#
class AWSLoader::ElasticLoadBalancingV2 < GraphDbLoader
  def load_balancer
    node = 'AWS_ELASTIC_LOAD_BALANCER'
    q = []

    # load_balancer node
    q.push(_upsert({ node: node, id: @name }))

    # logging enabled?
    logging_enabled = @data&.attributes&.find { |a| a.key == 'access_logs.s3.enabled'}&.value || false

    # append logging attributes
    q.push(_append({ node: node, id: @name, data: { logging_enabled: logging_enabled } }))

    q
  end
end

# frozen_string_literal: true

#
# Load ElasticLoadBalancing (v1) assets into RedisGraph
#
# Each method returns an array of Cypher queries
#
class AWSLoader::ElasticLoadBalancing < GraphDbLoader
  def load_balancer
    node = 'AWS_ELASTIC_LOAD_BALANCER'
    q = []

    # load_balancer node
    q.push(_upsert({ node: node, id: @name }))

    # logging enabled?
    logging_enabled = @data&.attributes&.access_log&.enabled || false

    # append logging attributes
    q.push(_append({ node: node, id: @name, data: { logging_enabled: logging_enabled } }))

    q
  end
end

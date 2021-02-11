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

    @data&.listener_descriptions&.each_with_index do |listener, i|
      opts = {
        parent_node: node,
        parent_name: @name,
        child_node: 'AWS_ELASTIC_LOAD_BALANCER_LISTENER',
        child_name: "#{@data.dns_name}/listener-#{i}",
        relationship: 'HAS_LISTENER',
        relationship_attributes: {
          port: listener.listener.load_balancer_port,
          protocol: listener.listener.protocol.downcase,
          ssl_certificate_id: listener.listener.ssl_certificate_id
        },
        headless: true
      }

      q.push(_upsert_and_link(opts))
    end

    q
  end
end

# frozen_string_literal: true

#
# Load ElasticsearchService assets into RedisGraph
#
# Each method returns an array of Cypher queries
#
class AWSLoader::ElasticsearchService < GraphDbLoader
  def domain
    node = 'AWS_ELASTICSEARCH_DOMAIN'
    q = []

    # domain node
    q.push(_upsert({ node: node, id: @name }))

    # additional attributes
    enforce_https = @data&.domain_endpoint_options&.enforce_https || false
    encryption_at_rest = @data&.encryption_at_rest_options&.enabled || false
    node_to_node = @data&.node_to_node_encryption_options&.enabled || false
    log_publishing_options = @data&.log_publishing_options&.to_h&.keys&.join(',')
    cognito_options = @data&.cognito_options&.enabled || false

    q.push(_append({ node: node, id: @name,
                     data: {
                       enforce_https_enabled: enforce_https,
                       encryption_at_rest_enabled: encryption_at_rest,
                       node_to_node_encryption_options: node_to_node,
                       log_publishing_options: log_publishing_options,
                       cognito_options_enabled: cognito_options
                     }}))

    q
  end
end

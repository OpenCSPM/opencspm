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
    vpc_id = @data&.vpc_options&.vpc_id
    enforce_https = @data&.domain_endpoint_options&.enforce_https || false
    encryption_at_rest = @data&.encryption_at_rest_options&.enabled || false
    node_to_node = @data&.node_to_node_encryption_options&.enabled || false
    log_errors = @data&.log_publishing_options&.ES_APPLICATION_LOGS&.enabled || false
    log_index_slow = @data&.log_publishing_options&.INDEX_SLOW_LOGS&.enabled || false
    log_search_slow = @data&.log_publishing_options&.SEARCH_SLOW_LOGS&.enabled || false
    cognito_options = @data&.cognito_options&.enabled || false

    q.push(_append({ node: node, id: @name,
                     data: {
                       vpc_id: vpc_id,
                       enforce_https_enabled: enforce_https,
                       encryption_at_rest_enabled: encryption_at_rest,
                       node_to_node_encryption_options: node_to_node,
                       cognito_options_enabled: cognito_options,
                       log_errors: log_errors,
                       log_index_slow: log_index_slow,
                       log_search_slow: log_search_slow
                     }}))

    q
  end
end

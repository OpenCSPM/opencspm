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

    # additional attributes
    logging_enabled = @data&.attributes&.find { |a| a.key == 'access_logs.s3.enabled'}&.value || false
    drop_invalid_header_fields = @data&.attributes&.find { |a| a.key == 'routing.http.drop_invalid_header_fields.enabled'}&.value || false
    fail_open_waf = @data&.attributes&.find { |a| a.key == 'waf.fail_open.enabled'}&.value || false
    desync_mitigation = @data&.attributes&.find { |a| a.key == 'routing.http.desync_mitigation_mode'}&.value || 'none'

    # append additional attributes
    q.push(_append({ node: node, id: @name,
                     data: {
                       logging_enabled: logging_enabled,
                       drop_invalid_header_fields: drop_invalid_header_fields,
                       fail_open_waf: fail_open_waf,
                       desync_mitigation: desync_mitigation
                     }}))

    q
  end
end

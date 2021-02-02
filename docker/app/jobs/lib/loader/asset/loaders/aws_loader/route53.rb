# frozen_string_literal: true

#
# Load Route53 assets into RedisGraph
#
# Each method returns an array of Cypher queries
#
class AWSLoader::Route53 < GraphDbLoader
  def zone
    node = 'AWS_ROUTE53_ZONE'
    q = []

    # zone node
    q.push(_upsert({ node: node, id: @name }))

    q.push(_append({ node: node, id: @name, data: {
                     cloud_watch_logs_log_group_arn: @data&.logging_config&.cloud_watch_logs_log_group_arn || 'none'
                   } }))

    q
  end
end

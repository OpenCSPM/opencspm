#
# Load CloudWatch assets into RedisGraph
#
# Each method returns an array of Cypher queries
#
class AWSLoader::CloudWatch < GraphDbLoader
  def metric_alarm
    node = 'AWS_CLOUDWATCH_METRIC_ALARM'
    q = []

    # metric_alarm node
    q.push(_upsert({ node: node, id: @name }))
    q
  end
end

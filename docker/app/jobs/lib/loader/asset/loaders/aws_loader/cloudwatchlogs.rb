#
# Load CloudWatchLogs assets into RedisGraph
#
# Each method returns an array of Cypher queries
#
class AWSLoader::CloudWatchLogs < GraphDbLoader
  def log_group
    node = 'AWS_CLOUDWATCH_LOG_GROUP'
    q = []

    # log_group node
    q.push(_upsert({ node: node, id: @name }))
  end
end

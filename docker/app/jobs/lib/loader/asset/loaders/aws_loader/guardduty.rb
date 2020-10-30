#
# Load GuardDuty assets into RedisGraph
#
# Each method returns an array of Cypher queries
#
class AWSLoader::GuardDuty < GraphDbLoader
  def detector
    node = 'AWS_GUARDDUTY_DETECTOR'
    q = []

    # detector node
    q.push(_upsert({ node: node, id: @name }))

    q
  end
end

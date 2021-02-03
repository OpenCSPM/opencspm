# frozen_string_literal: true

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

    # detector findings statistics
    q.push(_append({ node: node, id: @name, data: {
                     findings: @data&.findings_statistics&.count_by_severity&.to_h&.values&.inject(:+) || 0,
                     findings_aged_short: @data&.findings_statistics_aged_short&.count_by_severity&.to_h&.values&.inject(:+) || 0,
                     findings_aged_long: @data&.findings_statistics_aged_long&.count_by_severity&.to_h&.values&.inject(:+) || 0
                   } }))

    q
  end
end

# frozen_string_literal: true

#
# Load ConfigService assets into RedisGraph
#
# Each method returns an array of Cypher queries
#
class AWSLoader::ConfigService < GraphDbLoader
  def rule
    node = 'AWS_CONFIG_RULE'
    q = []

    # rule node
    q.push(_upsert({ node: node, id: @name }))

    q
  end

  def delivery_channel
    node = 'AWS_CONFIG_DELIVERY_CHANNEL'
    q = []

    # delivery_channel node
    q.push(_upsert({ node: node, id: @name }))

    q
  end

  def configuration_recorder
    node = 'AWS_CONFIG_CONFIGURATION_RECORDER'
    q = []

    # configuration_recorder node
    q.push(_upsert({
                     node: node,
                     id: @name,
                     data: {}.merge(@data.recording_group.to_h).merge(@data.status.to_h)
                   }))

    q
  end
end

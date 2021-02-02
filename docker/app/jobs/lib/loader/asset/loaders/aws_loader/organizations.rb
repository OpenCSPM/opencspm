# frozen_string_literal: true

#
# Load Organizations assets into RedisGraph
#
# Each method returns an array of Cypher queries
#
class AWSLoader::Organizations < GraphDbLoader
  def organization
    node = 'AWS_ORGANIZATION'
    q = []

    account_id = "arn:aws:::#{@account}/account"

    # organization node
    q.push(_upsert({ node: node, id: @name }))

    # account node
    q.push(_upsert({ node: 'AWS_ACCOUNT', id: account_id }))

    # account -> organization
    opts = {
      from_node: 'AWS_ORGANIZATION',
      from_name: @name,
      to_node: 'AWS_ACCOUNT',
      to_name: account_id,
      relationship: 'MEMBER_OF_ORGANIZATION'
    }

    q.push(_link(opts))

    q
  end

  def handshake
    node = 'AWS_ORGANIZATION_HANDSHAKE'
    q = []

    # handshake node
    q.push(_upsert({ node: node, id: @name }))

    q
  end
end

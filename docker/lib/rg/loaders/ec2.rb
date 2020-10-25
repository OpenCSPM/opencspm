#
# Load EC2 assets into RedisGraph
#
# Load all top-level resources first;
# TODO: map a LIVES_IN/RUNS_IN relationship for each resource to the region
#
class AwsEc2Loader < AwsGraphDbLoader
  # generate Cypher query strings
  # TODO: array of multiple queries?
  def to_q
    return _instance if @asset_type == 'instance'
    return _vpc if @asset_type == 'vpc'
    return _security_group if @asset_type == 'security_group'
    return _network_interface if @asset_type == 'network_interface'
    return _subnet if @asset_type == 'subnet'
    return _address if @asset_type == 'eip_address'
    return _nat_gateway if @asset_type == 'nat_gateway'
    return _route_table if @asset_type == 'route_table'
    return _image if @asset_type == 'image'
    return _snapshot if @asset_type == 'snapshot'
    return _flow_log if @asset_type == 'flow_log'
    return _volume if @asset_type == 'volume'
    return _vpn_gateway if @asset_type == 'vpn_gateway'
    return _vpc_peering_connection if @asset_type == 'peering_connection'
  end

  private

  #
  # belongs_to: vpc
  # has_many: network_interfaces
  # has_many: security_groups,  through: network_interfaces
  # has_many: subnets,          through: network_interfaces
  #
  def _instance
    node = 'AWS_INSTANCE'
    q = []

    # instance node
    q.push(_build_query(node))

    # vpc node and relationship
    if @data.vpc_id
      opts = {
        parent_node: 'AWS_VPC',
        parent_name: @data.vpc_id,
        parent_asset_type: 'vpc',
        service: 'EC2',
        child_node: node,
        child_name: @name,
        relationship: 'MEMBER_OF'
      }

      q.push(_merge_query(opts))
    end

    # network_interfaces and relationship
    @data.network_interfaces.each do |ni|
      opts = {
        parent_node: 'AWS_NETWORK_INTERFACE',
        parent_name: ni.network_interface_id,
        parent_asset_type: 'instance',
        service: 'EC2',
        child_node: node,
        child_name: @name,
        relationship: 'ATTACHED_TO'
      }

      q.push(_merge_query(opts))
    end

    q
  end

  #
  # has_many: instances
  # has_many: network_interfaces
  # has_many: security_groups,    through: network_interfaces
  #
  def _vpc
    q = []

    # vpc node
    q.push(_build_query('AWS_VPC'))
  end

  #
  # belongs_to: instance
  # belongs_to: vpc
  #
  def _security_group
    node = 'AWS_SECURITY_GROUP'
    q = []

    # security_group node
    q.push(_build_query(node))

    # vpc node and relationship
    if @data.vpc_id
      opts = {
        parent_node: 'AWS_VPC',
        parent_name: @data.vpc_id,
        parent_asset_type: 'vpc',
        service: 'EC2',
        child_node: node,
        child_name: @name,
        relationship: 'MEMBER_OF'
      }

      q.push(_merge_query(opts))
    end
  end

  #
  # belongs_to: instance
  # belongs_to: vpc
  # belongs_to: subnet
  # has_many: security_group
  #
  def _network_interface
    node = 'AWS_NETWORK_INTERFACE'
    q = []

    # network interface
    q.push(_build_query(node))

    # vpc node and relationship
    if @data.vpc_id
      opts = {
        parent_node: 'AWS_VPC',
        parent_name: @data.vpc_id,
        parent_asset_type: 'vpc',
        service: 'EC2',
        child_node: node,
        child_name: @name,
        relationship: 'MEMBER_OF'
      }

      q.push(_merge_query(opts))
    end

    # security_groups and relationship
    @data.groups.each do |sg|
      opts = {
        parent_node: 'AWS_SECURITY_GROUP',
        parent_name: sg.group_id,
        parent_asset_type: 'security_group',
        service: 'EC2',
        child_node: node,
        child_name: @name,
        relationship: 'IN_GROUP'
      }

      q.push(_merge_query(opts))
    end

    q
  end

  def _subnet
    q = []

    q.push(_build_query('AWS_SUBNET'))
  end

  def _address
    q = []

    q.push(_build_query('AWS_EIP_ADDRESS'))
  end

  def _nat_gateway
    q = []

    q.push(_build_query('AWS_NAT_GATEWAY'))
  end

  def _route_table
    q = []

    q.push(_build_query('AWS_ROUTE_TABLE'))
  end

  def _image
    q = []

    q.push(_build_query('AWS_IMAGE'))
  end

  def _snapshot
    q = []

    q.push(_build_query('AWS_SNAPSHOT'))
  end

  def _flow_log
    q = []

    q.push(_build_query('AWS_FLOW_LOG'))
  end

  def _volume
    q = []

    q.push(_build_query('AWS_VOLUME'))
  end

  def _vpn_gateway
    q = []

    q.push(_build_query('AWS_VPN_GATEWAY'))
  end

  def _vpc_peering_connection
    q = []

    q.push(_build_query('AWS_PEERING_CONNECTION'))
  end
end

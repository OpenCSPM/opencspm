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
    q.push(_upsert({ node: node, id: @name }))

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

      q.push(_upsert_and_link(opts))
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

      q.push(_upsert_and_link(opts))
    end

    # security_groups and relationship
    @data.security_groups.each do |sg|
      opts = {
        parent_node: 'AWS_SECURITY_GROUP',
        parent_name: sg.group_id,
        parent_asset_type: 'instance',
        service: 'EC2',
        child_node: node,
        child_name: @name,
        relationship: 'IN_GROUP'
      }

      q.push(_upsert_and_link(opts))
    end

    # subnets and relationship
    if @data.subnet_id
      opts = {
        parent_node: 'AWS_SUBNET',
        # parent_name: "arn:aws:ec2:#{@region}:#{@account}:subnet/#{@data.subnet_id}",
        parent_name: @data.subnet_id,
        parent_asset_type: 'instance',
        service: 'EC2',
        child_node: node,
        child_name: @name,
        relationship: 'IN_SUBNET'
      }

      q.push(_upsert_and_link(opts))
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
    q.push(_upsert({ node: 'AWS_VPC', id: @name }))
  end

  #
  # belongs_to: instance
  # belongs_to: vpc
  #
  def _security_group
    node = 'AWS_SECURITY_GROUP'
    q = []

    # security_group node
    q.push(_upsert({ node: node, id: @name }))

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

      q.push(_upsert_and_link(opts))
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
    q.push(_upsert({ node: node, id: @name }))

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

      q.push(_upsert_and_link(opts))
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

      q.push(_upsert_and_link(opts))
    end

    q
  end

  def _subnet
    node = 'AWS_SUBNET'
    q = []

    # use subnet_id instead of ARN
    q.push(_upsert({ node: node, id: @data.subnet_id }))

    # vpc node and relationship
    if @data.vpc_id
      opts = {
        parent_node: 'AWS_VPC',
        parent_name: @data.vpc_id,
        parent_asset_type: 'vpc',
        service: 'EC2',
        child_node: node,
        # child_name: @name,
        child_name: @data.subnet_id,
        relationship: 'MEMBER_OF'
      }

      q.push(_upsert_and_link(opts))
    end

    q
  end

  def _address
    node = 'AWS_EIP_ADDRESS'
    q = []

    q.push(_upsert({ node: node, id: @name }))
  end

  def _nat_gateway
    node = 'AWS_NAT_GATEWAY'
    q = []

    q.push(_upsert({ node: node, id: @name }))
  end

  def _route_table
    node = 'AWS_ROUTE_TABLE'
    q = []

    q.push(_upsert({ node: node, id: @name }))
  end

  def _image
    node = 'AWS_IMAGE'
    q = []

    q.push(_upsert({ node: node, id: @name }))
  end

  def _snapshot
    node = 'AWS_SNAPSHOT'
    q = []

    q.push(_upsert({ node: node, id: @name }))
  end

  def _flow_log
    node = 'AWS_FLOW_LOG'
    q = []

    q.push(_upsert({ node: node, id: @name }))
  end

  def _volume
    node = 'AWS_VOLUME'
    q = []

    q.push(_upsert({ node: node, id: @name }))
  end

  def _vpn_gateway
    node = 'AWS_VPN_GATEWAY'
    q = []

    q.push(_upsert({ node: node, id: @name }))
  end

  def _vpc_peering_connection
    node = 'AWS_PEERING_CONNECTION'
    q = []

    q.push(_upsert({ node: node, id: @name }))
  end
end

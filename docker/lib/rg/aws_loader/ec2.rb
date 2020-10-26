#
# Load EC2 assets into RedisGraph
#
# Each method returns an array of Cypher queries
#
class AWSLoader::EC2 < AwsGraphDbLoader
  #
  # belongs_to: vpc
  # has_many: network_interfaces
  # has_many: security_groups,  through: network_interfaces
  # has_many: subnets,          through: network_interfaces
  #
  def instance
    node = 'AWS_INSTANCE'
    q = []

    # instance node
    q.push(_upsert({ node: node, id: @name }))

    # vpc node and relationship
    if @data.vpc_id
      opts = {
        parent_node: 'AWS_VPC',
        parent_name: @data.vpc_id,
        child_node: node,
        child_name: @name,
        relationship: 'MEMBER_OF_VPC'
      }

      q.push(_upsert_and_link(opts))
    end

    # network_interfaces and relationship
    @data.network_interfaces.each do |ni|
      opts = {
        parent_node: 'AWS_NETWORK_INTERFACE',
        parent_name: ni.network_interface_id,
        child_node: node,
        child_name: @name,
        relationship: 'ATTACHED_TO_INSTANCE'
      }

      q.push(_upsert_and_link(opts))
    end

    # security_groups and relationship
    @data.security_groups.each do |sg|
      opts = {
        parent_node: 'AWS_SECURITY_GROUP',
        parent_name: sg.group_id,
        child_node: node,
        child_name: @name,
        relationship: 'IN_SECURITY_GROUP'
      }

      q.push(_upsert_and_link(opts))
    end

    # subnet and relationship
    if @data.subnet_id
      opts = {
        parent_node: 'AWS_SUBNET',
        # parent_name: "arn:aws:ec2:#{@region}:#{@account}:subnet/#{@data.subnet_id}",
        parent_name: @data.subnet_id,
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
  def vpc
    q = []

    # vpc node
    q.push(_upsert({ node: 'AWS_VPC', id: @name }))
  end

  #
  # belongs_to: instance
  # belongs_to: vpc
  #
  def security_group
    node = 'AWS_SECURITY_GROUP'
    q = []

    # security_group node
    q.push(_upsert({ node: node, id: @name }))

    # vpc node and relationship
    if @data.vpc_id
      opts = {
        parent_node: 'AWS_VPC',
        parent_name: @data.vpc_id,
        child_node: node,
        child_name: @name,
        relationship: 'MEMBER_OF_VPC'
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
  def network_interface
    node = 'AWS_NETWORK_INTERFACE'
    q = []

    # network interface
    q.push(_upsert({ node: node, id: @name }))

    # vpc node and relationship
    if @data.vpc_id
      opts = {
        parent_node: 'AWS_VPC',
        parent_name: @data.vpc_id,
        child_node: node,
        child_name: @name,
        relationship: 'MEMBER_OF_VPC'
      }

      q.push(_upsert_and_link(opts))
    end

    # security_groups and relationship
    @data.groups.each do |sg|
      opts = {
        parent_node: 'AWS_SECURITY_GROUP',
        parent_name: sg.group_id,
        child_node: node,
        child_name: @name,
        relationship: 'IN_SECURITY_GROUP'
      }

      q.push(_upsert_and_link(opts))
    end

    q
  end

  def subnet
    node = 'AWS_SUBNET'
    q = []

    # use subnet_id instead of ARN
    q.push(_upsert({ node: node, id: @data.subnet_id }))

    # vpc node and relationship
    if @data.vpc_id
      opts = {
        parent_node: 'AWS_VPC',
        parent_name: @data.vpc_id,
        child_node: node,
        # child_name: @name,
        child_name: @data.subnet_id,
        relationship: 'MEMBER_OF_VPC'
      }

      q.push(_upsert_and_link(opts))
    end

    q
  end

  def address
    node = 'AWS_EIP_ADDRESS'
    q = []

    q.push(_upsert({ node: node, id: @name }))
  end

  def nat_gateway
    node = 'AWS_NAT_GATEWAY'
    q = []

    q.push(_upsert({ node: node, id: @name }))
  end

  def route_table
    node = 'AWS_ROUTE_TABLE'
    q = []

    q.push(_upsert({ node: node, id: @name }))
  end

  def image
    node = 'AWS_IMAGE'
    q = []

    q.push(_upsert({ node: node, id: @name }))
  end

  def snapshot
    node = 'AWS_SNAPSHOT'
    q = []

    q.push(_upsert({ node: node, id: @name }))
  end

  def flow_log
    node = 'AWS_FLOW_LOG'
    q = []

    q.push(_upsert({ node: node, id: @name }))
  end

  def volume
    node = 'AWS_VOLUME'
    q = []

    q.push(_upsert({ node: node, id: @name }))
  end

  def vpn_gateway
    node = 'AWS_VPN_GATEWAY'
    q = []

    q.push(_upsert({ node: node, id: @name }))
  end

  # vpc peering connection
  def peering_connection
    node = 'AWS_PEERING_CONNECTION'
    q = []

    q.push(_upsert({ node: node, id: @name }))
  end
end

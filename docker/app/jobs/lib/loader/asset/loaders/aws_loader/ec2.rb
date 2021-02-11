# frozen_string_literal: true

#
# Load EC2 assets into RedisGraph
#
# Each method returns an array of Cypher queries
#
# Example query:
#   MATCH (i:AWS_EC2_INSTANCE)
#   OPTIONAL MATCH (i:AWS_EC2_INSTANCE)-[:MEMBER_OF_VPC]-(v:AWS_VPC)
#   OPTIONAL MATCH (e:AWS_EKS_CLUSTER)-[:MEMBER_OF_VPC]-(v:AWS_VPC)
#   RETURN i,v,e
#
class AWSLoader::EC2 < GraphDbLoader
  def account
    node = 'AWS_EC2_ACCOUNT'
    name = "account-#{@account}" # AWS account doesn't have an ARN
    q = []

    # account node
    q.push(_upsert({ node: node, id: name }))
  end

  #
  # belongs_to: vpc
  # has_many: network_interfaces
  # has_many: security_groups,  through: network_interfaces
  # has_many: subnets,          through: network_interfaces
  #
  def instance
    node = 'AWS_EC2_INSTANCE'
    q = []

    # instance node
    q.push(_upsert({ node: node, id: @name }))

    # vpc node and relationship
    if @data.vpc_id
      opts = {
        parent_node: node,
        parent_name: @name,
        child_node: 'AWS_VPC',
        child_name: @data.vpc_id,
        relationship: 'MEMBER_OF_VPC'
      }

      q.push(_upsert_and_link(opts))
    end

    # network_interfaces and relationship
    @data.network_interfaces.each do |ni|
      opts = {
        parent_node: node,
        parent_name: @name,
        child_node: 'AWS_NETWORK_INTERFACE',
        child_name: ni.network_interface_id,
        relationship: 'ATTACHED_TO_INSTANCE'
      }

      q.push(_upsert_and_link(opts))
    end

    # security_groups and relationship
    @data.security_groups.each do |sg|
      opts = {
        child_node: 'AWS_SECURITY_GROUP',
        child_name: sg.group_id,
        parent_node: node,
        parent_name: @name,
        relationship: 'IN_SECURITY_GROUP'
      }

      q.push(_upsert_and_link(opts))
    end

    # subnet and relationship
    if @data.subnet_id
      opts = {
        parent_node: node,
        parent_name: @name,
        child_node: 'AWS_SUBNET',
        # child_name: "arn:aws:ec2:#{@region}:#{@account}:subnet/#{@data.subnet_id}",
        child_name: @data.subnet_id,
        relationship: 'IN_SUBNET'
      }

      q.push(_upsert_and_link(opts))
    end

    if @data.iam_instance_profile
      opts = {
        node: 'AWS_EC2_IAM_PROFILE',
        id: @data.iam_instance_profile.arn
      }

      q.push(_merge(opts))

      opts = {
        from_node: node,
        from_name: @name,
        to_node: 'AWS_EC2_IAM_PROFILE',
        to_name: @data.iam_instance_profile.arn,
        relationship: 'HAS_IAM_PROFILE'
      }

      q.push(_link(opts))
    end

    if @data.metadata_options
      metadata_options = "#{@name}-metadata-options"

      opts = {
        node: 'AWS_EC2_INSTANCE_METADATA_OPTIONS',
        id: metadata_options
      }

      q.push(_merge(opts))

      opts = {
        from_node: node,
        from_name: @name,
        to_node: 'AWS_EC2_INSTANCE_METADATA_OPTIONS',
        to_name: metadata_options,
        relationship: 'HAS_METADATA_OPTIONS',
        relationship_attributes: @data.metadata_options.to_h
      }

      q.push(_link(opts))
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
        parent_node: node,
        parent_name: @name,
        child_node: 'AWS_VPC',
        child_name: @data.vpc_id,
        relationship: 'MEMBER_OF_VPC'
      }

      q.push(_upsert_and_link(opts))
    end

    # ingress rules
    @data.ip_permissions.each do |ingress|
      ingress.ip_ranges.each_with_index do |ip_range, i|
        opts = {
          parent_node: node,
          parent_name: @name,
          child_node: 'AWS_SECURITY_GROUP_INGRESS_RULE',
          child_name: "#{@name}-#{ingress.ip_protocol}-#{ingress.to_port}-#{i}",
          relationship: 'HAS_INGRESS_RULE',
          relationship_attributes: {
            cidr_ip: ip_range.cidr_ip,
            ip_protocol: ingress.ip_protocol,
            to_port: ingress.to_port,
            from_port: ingress.from_port,
            direction: 'ingress'
          }
        }

        q.push(_upsert_and_link(opts))
      end
    end

    # egress rules
    @data.ip_permissions_egress.each do |egress|
      egress.ip_ranges.each_with_index do |ip_range, i|
        opts = {
          parent_node: node,
          parent_name: @name,
          child_node: 'AWS_SECURITY_GROUP_EGRESS_RULE',
          child_name: "#{@name}-#{egress.ip_protocol}-#{egress.to_port}-#{i}",
          relationship: 'HAS_EGRESS_RULE',
          relationship_attributes: {
            cidr_ip: ip_range.cidr_ip,
            ip_protocol: egress.ip_protocol,
            to_port: egress.to_port,
            from_port: egress.from_port,
            direction: 'egress'
          }
        }

        q.push(_upsert_and_link(opts))
      end
    end

    q
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
        parent_node: node,
        parent_name: @name,
        child_node: 'AWS_VPC',
        child_name: @data.vpc_id,
        relationship: 'MEMBER_OF_VPC'
      }

      q.push(_upsert_and_link(opts))
    end

    # security_groups and relationship
    @data.groups.each do |sg|
      opts = {
        node: 'AWS_SECURITY_GROUP',
        id: sg.group_id,
        headless: true
      }

      q.push(_merge(opts))

      # network_interface -> security_group
      opts = {
        from_node: 'AWS_NETWORK_INTERFACE',
        from_name: @name,
        to_node: 'AWS_SECURITY_GROUP',
        to_name: sg.group_id,
        relationship: 'IN_SECURITY_GROUP',
        headless: true
      }
      q.push(_link(opts))
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
        parent_node: node,
        # parent_name: @name,
        parent_name: @data.subnet_id,
        child_node: 'AWS_VPC',
        child_name: @data.vpc_id,
        relationship: 'MEMBER_OF_VPC'
      }

      q.push(_upsert_and_link(opts))
    end

    q
  end

  def eip_address
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

    q.push(_append({ node: node, id: @name, data: {
                     create_volume_permissions: @data&.create_volume_permissions&.map(&:group)&.join(','),
                     state: @data.state # re-write another field so append isn't empty
                   } }))
  end

  def flow_log
    node = 'AWS_FLOW_LOG'
    q = []

    q.push(_upsert({ node: node, id: @name }))

    # vpc/subnet/network-interface node and relationship
    if @data.resource_id
      resource_node_type = if @data.resource_id.starts_with?('eni-')
                             'AWS_NETWORK_INTERFACE'
                           elsif @data.resource_id.starts_with?('vpc-')
                             'AWS_VPC'
                           elsif @data.resource_id.starts_with?('subnet-')
                             'AWS_SUBNET'
                           end

      opts = {
        parent_node: node,
        parent_name: @name,
        child_node: resource_node_type,
        child_name: @data.resource_id,
        relationship: 'HAS_FLOW_LOG',
        relationship_attributes: { status: @data.flow_log_status }
      }

      q.push(_upsert_and_link(opts)) if resource_node_type
    end

    q
  end

  def volume
    node = 'AWS_EBS_VOLUME'
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

  def ebs_encryption_settings
    node = 'AWS_EBS_ENCRYPTION_SETTINGS'
    name = "#{@region}-#{@account}"
    q = []

    q.push(_upsert({ node: node, id: name }))
  end

  def internet_gateway
    node = 'AWS_INTERNET_GATEWAY'
    name = "arn:aws:ec2:#{@region}:#{@account}:internet_gateway/#{@name}"
    q = []

    q.push(_upsert({ node: node, id: name }))
  end

  def network_acl
    node = 'AWS_NETWORK_ACL'
    name = "arn:aws:ec2:#{@region}:#{@account}:network_acl/#{@name}"
    q = []

    q.push(_upsert({ node: node, id: name }))
  end
end

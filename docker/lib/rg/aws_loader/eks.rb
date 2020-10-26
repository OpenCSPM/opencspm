#
# Load EKS assets into RedisGraph
#
# Each method returns an array of Cypher queries
#
class AWSLoader::EKS < AwsGraphDbLoader
  def cluster
    node = 'AWS_EKS_CLUSTER'
    q = []

    # instance node
    q.push(_upsert({ node: node, id: @data.arn }))

    # vpc node and relationship
    if @data.resources_vpc_config&.vpc_id
      opts = {
        parent_node: 'AWS_VPC',
        parent_name: @data.resources_vpc_config.vpc_id,
        parent_asset_type: 'vpc',
        service: 'EKS',
        child_node: node,
        child_name: @data.arn,
        relationship: 'MEMBER_OF'
      }

      q.push(_upsert_and_link(opts))
    end

    # subnets and relationship
    @data.resources_vpc_config&.subnet_ids&.each do |subnet_id|
      opts = {
        parent_node: 'AWS_SUBNET',
        parent_name: subnet_id,
        parent_asset_type: 'vpc',
        service: 'EKS',
        child_node: node,
        child_name: @data.arn,
        relationship: 'IN_SUBNET'
      }

      q.push(_upsert_and_link(opts))
    end

    # TODO: nodegroups

    # TODO: nodes

    # logging types
    @data.logging&.cluster_logging&.each do |logging|
      if logging.types
        data = { logging_types: logging.types.join(', ') }
        q.push(_append({node: node, id: @data.arn, data: data}))
      end
    end

    q
  end
end

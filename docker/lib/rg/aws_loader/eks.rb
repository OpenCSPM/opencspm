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
        parent_service: 'EKS',
        child_node: node,
        child_name: @data.arn,
        relationship: 'MEMBER_OF_VPC'
      }

      q.push(_upsert_and_link(opts))
    end

    # subnets and relationship
    @data.resources_vpc_config&.subnet_ids&.each do |subnet_id|
      opts = {
        parent_node: 'AWS_SUBNET',
        parent_name: subnet_id,
        parent_asset_type: 'vpc',
        parent_service: 'EKS',
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
      logging.types.each do |logging_type|
        opts = {
          parent_node: 'AWS_EKS_CLUSTER_LOGGING_TYPE',
          parent_name: logging_type,
          parent_asset_type: 'cluster',
          parent_service: 'EKS',
          child_node: 'AWS_EKS_CLUSTER',
          child_name: @data.arn,
          relationship: 'HAS_LOGGING_TYPE',
          relationship_attributes: { enabled: logging.enabled.to_s },
          headless: true
        }

        q.push(_upsert_and_link(opts))
      end
    end

    q
  end
end

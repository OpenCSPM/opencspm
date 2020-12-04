#
# Load EKS assets into RedisGraph
#
# Each method returns an array of Cypher queries
#
class AWSLoader::EKS < GraphDbLoader
  def cluster
    node = 'AWS_EKS_CLUSTER'
    q = []

    # instance node
    q.push(_upsert({ node: node, id: @data.arn }))

    # vpc node and relationship
    if @data.resources_vpc_config&.vpc_id
      opts = {
        parent_node: node,
        parent_name: @data.arn,
        child_node: 'AWS_VPC',
        child_name: @data.resources_vpc_config.vpc_id,
        relationship: 'MEMBER_OF_VPC'
      }

      q.push(_upsert_and_link(opts))
    end

    # subnets and relationship
    @data.resources_vpc_config&.subnet_ids&.each do |subnet_id|
      opts = {
        parent_node: node,
        parent_name: @data.arn,
        child_node: 'AWS_SUBNET',
        child_name: subnet_id,
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
          parent_node: 'AWS_EKS_CLUSTER',
          parent_name: @data.arn,
          child_node: 'AWS_EKS_CLUSTER_LOGGING_TYPE',
          child_name: logging_type,
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

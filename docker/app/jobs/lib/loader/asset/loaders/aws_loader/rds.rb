# frozen_string_literal: true

#
# Load RDS assets into RedisGraph
#
# Each method returns an array of Cypher queries
#
class AWSLoader::RDS < GraphDbLoader
  def db_cluster
    node = 'AWS_RDS_CLUSTER'
    q = []

    # rds cluster node
    q.push(_upsert({ node: node, id: @data.arn }))

    cloudwatch_logs_exports = @data&.enabled_cloudwatch_logs_exports&.join(',') || false

    q.push(_append({ node: node, id: @data.arn, data: {
                     enabled_cloudwatch_logs_exports: cloudwatch_logs_exports
                   }}))

    # security_groups and relationship
    @data.vpc_security_groups.each do |sg|
      opts = {
        parent_node: node,
        parent_name: @name,
        child_node: 'AWS_SECURITY_GROUP',
        child_name: sg.vpc_security_group_id,
        relationship: 'IN_SECURITY_GROUP'
      }

      q.push(_upsert_and_link(opts))
    end

    q
  end

  def db_cluster_snapshot
    node = 'AWS_RDS_CLUSTER_SNAPSHOT'
    q = []

    # cluster snapshot node
    q.push(_upsert({ node: node, id: @data.arn }))

    # cluster relationship
    if @data.db_cluster_identifier
      opts = {
        parent_node: 'AWS_RDS_CLUSTER',
        parent_name: "arn:aws:rds:#{@region}:#{@account}:cluster:#{@data.db_cluster_identifier}",
        child_node: node,
        child_name: @name,
        relationship: 'HAS_SNAPSHOT'
      }

      q.push(_upsert_and_link(opts))
    end

    q
  end

  def db_instance
    node = 'AWS_RDS_INSTANCE'
    q = []

    # rds instance node
    q.push(_upsert({ node: node, id: @name }))

    cloudwatch_logs_exports = @data&.enabled_cloudwatch_logs_exports&.join(',') || false

    q.push(_append({ node: node, id: @name, data: {
                     enabled_cloudwatch_logs_exports: cloudwatch_logs_exports
                   }}))

    # cluster relationship
    if @data.db_cluster_identifier
      opts = {
        parent_node: 'AWS_RDS_CLUSTER',
        parent_name: "arn:aws:rds:#{@region}:#{@account}:cluster:#{@data.db_cluster_identifier}",
        child_node: node,
        child_name: @name,
        relationship: 'MEMBER_OF_RDS_CLUSTER'
      }

      q.push(_upsert_and_link(opts))
    end

    q
  end

  def db_snapshot
    node = 'AWS_RDS_SNAPSHOT'
    q = []

    # snapshot node
    q.push(_upsert({ node: node, id: @data.arn }))

    # instance relationship
    if @data.db_instance_identifier
      opts = {
        parent_node: 'AWS_RDS_INSTANCE',
        parent_name: "arn:aws:rds:#{@region}:#{@account}:db:#{@data.db_instance_identifier}",
        child_node: node,
        child_name: @name,
        relationship: 'HAS_SNAPSHOT'
      }

      q.push(_upsert_and_link(opts))
    end

    q
  end

  # ignore
  def db_engine_version
    nil
  end
end

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

  def db_instance
    node = 'AWS_RDS_INSTANCE'
    q = []

    # rds instance node
    q.push(_upsert({ node: node, id: @name }))

    # cluster relationship
    if @data.db_cluster_identifier
      opts = {
        parent_node: node,
        parent_name: @name,
        child_node: 'AWS_RDS_CLUSTER',
        child_name: "arn:aws:rds:#{@region}:#{@account}:cluster:#{@data.db_cluster_identifier}",
        # child_name: @data.db_cluster_identifier,
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
        parent_node: node,
        parent_name: @name,
        child_node: 'AWS_RDS_INSTANCE',
        child_name: "arn:aws:rds:#{@region}:#{@account}:db:#{@data.db_instance_identifier}",
        # child_name: @data.db_instance_identifier,
        relationship: 'SNAPSHOT_OF_RDS_INSTANCE'
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

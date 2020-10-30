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
        parent_node: 'AWS_SECURITY_GROUP',
        parent_name: sg.vpc_security_group_id,
        child_node: node,
        child_name: @name,
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
        parent_node: 'AWS_RDS_CLUSTER',
        parent_name: "arn:aws:rds:#{@region}:#{@account}:cluster:#{@data.db_cluster_identifier}",
        # parent_name: @data.db_cluster_identifier,
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
        # parent_name: @data.db_instance_identifier,
        child_node: node,
        child_name: @name,
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

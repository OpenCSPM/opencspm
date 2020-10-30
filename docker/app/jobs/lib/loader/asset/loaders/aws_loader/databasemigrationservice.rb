#
# Load DatabaseMigrationService assets into RedisGraph
#
# Each method returns an array of Cypher queries
#
class AWSLoader::DatabaseMigrationService < GraphDbLoader
  def replication_instance
    node = 'AWS_DMS_REPLICATION_INSTANCE'
    q = []

    # replication_instance node
    q.push(_upsert({ node: node, id: @name }))

    q
  end
end

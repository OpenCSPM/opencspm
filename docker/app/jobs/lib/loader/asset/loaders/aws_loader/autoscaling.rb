#
# Load AutoScaling assets into RedisGraph
#
# Each method returns an array of Cypher queries
#
class AWSLoader::AutoScaling < GraphDbLoader
  def auto_scaling_group
    node = 'AWS_AUTO_SCALING_GROUP'
    q = []

    # asg node
    q.push(_upsert({ node: node, id: @name }))

    # TODO: map instances to AWS_INSTANCEs
    # TODO: map availability_zones to AWS_AVAILABILITY_ZONEs
    # TODO: map vpc_zone_identifier to AWS_SUBNETs
    # TODO: map tags to AWS_TAGs
  end
end

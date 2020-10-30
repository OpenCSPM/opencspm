#
# Load ECR assets into RedisGraph
#
# Each method returns an array of Cypher queries
#
class AWSLoader::ECR < GraphDbLoader
  def repository
    node = 'AWS_ECR_REPOSITORY'
    q = []

    # repository node
    q.push(_upsert({ node: node, id: @data.arn }))

    # repository scan_on_push and encryption status
    if @data.image_scanning_configuration && @data.encryption_configuration
      opts = {
        node: node,
        id: @name,
        data: {
          scan_on_push: @data.image_scanning_configuration.scan_on_push,
          encryption_type: @data.encryption_configuration.encryption_type
        }
      }

      q.push(_append(opts))
    end

    q
  end
end

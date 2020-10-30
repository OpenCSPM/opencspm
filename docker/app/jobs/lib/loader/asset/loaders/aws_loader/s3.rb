#
# Load S3 assets into RedisGraph
#
# Each method returns an array of Cypher queries
#
class AWSLoader::S3 < GraphDbLoader
  def bucket
    node = 'AWS_S3_BUCKET'
    q = []

    # bucket node
    q.push(_upsert({ node: node, id: @name }))

    # owner
    if @data
      opts = {
        node: node,
        id: @name,
        data: {
          owner_display_name: @data&.acl&.owner&.display_name,
          owner_id: @data&.acl&.owner&.id,
          is_public: !!@data&.public&.is_public
        }
      }

      q.push(_append(opts))
    end

    q
  end

  # TODO: map acl grants
  # TODO: map acl policy
end

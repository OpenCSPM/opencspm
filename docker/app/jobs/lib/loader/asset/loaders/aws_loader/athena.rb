#
# Load Athena assets into RedisGraph
#
# Each method returns an array of Cypher queries
#
class AWSLoader::Athena < GraphDbLoader
  def workgroup
    node = 'AWS_ATHENA_WORKGROUP'
    q = []

    # workgroup node
    q.push(_upsert({ node: node, id: @name }))

    # workgroup details
    if @data&.details&.work_group
      opts = {
        node: node,
        id: @name,
        # TODO: improve mapping of work_group details (field name conflicts)
        data: {
          work_group_name: @data.details.work_group.name,
          work_group_state: @data.details.work_group.state
        }
      }

      q.push(_append(opts))
    end

    q
  end
end

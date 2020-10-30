#
# Load ElasticsearchService assets into RedisGraph
#
# Each method returns an array of Cypher queries
#
class AWSLoader::ElasticsearchService < GraphDbLoader
  def domain
    node = 'AWS_ELASTICSEARCH_DOMAIN'
    q = []

    # domain node
    q.push(_upsert({ node: node, id: @name }))

    q
  end
end

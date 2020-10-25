#
# Generic wrapper for loading AWS assets into RedisGragh
#
#
class AwsGraphDbLoader
  LOADER_TYPE = 'aws'.freeze
  FILTERED_ATTRIBUTES = [:user_data].freeze

  def initialize(json)
    @account = json.account
    @service = json.service
    @region = json.region
    @asset_type = json.asset_type
    @name = json.name
    @data = json.resource.data
  end

  private

  #
  # Cypher query to create/upsert a node
  #
  def _upsert(opts)
    o = OpenStruct.new(opts)

    raise ApplicationError::GraphLoaderParamsMissing unless o.node && o.id

    %(
      MERGE (n:#{o.node} { name: '#{o.id}' })
      ON CREATE SET #{_base_attrs('n')}
      ON MATCH SET #{_base_attrs('n')}
    )
  end

  #
  # Cypher query to find an existing node, create/upsert a parent node,
  # and attach a relationship
  #
  # e.g.  parent_node == 'AWS_VPC',
  #       parent_name == parent.arn,
  #       parent_asset_type == 'instance',
  #       service == 'EC2',
  #       child_node == 'AWS_INSTANCE',
  #       child_name == child.arn,
  #       relationship == 'IS_MEMBER_OF'
  def _upsert_and_link(opts)
    o = OpenStruct.new(opts)

    raise ApplicationError::GraphLoaderParamsMissing unless o.parent_node &&
                                                            o.parent_name &&
                                                            o.parent_asset_type &&
                                                            o.service &&
                                                            o.child_node &&
                                                            o.child_name &&
                                                            o.relationship

    %(
      MATCH (c:#{o.child_node} { name: '#{o.child_name}' })
      MERGE (p:#{o.parent_node} { name: '#{o.parent_name}' })
      ON CREATE SET #{_merge_base_attrs(o.service, o.parent_asset_type, 'p')}
      ON MATCH SET #{_merge_base_attrs(o.service, o.parent_asset_type, 'p')}
      MERGE (c)-[:#{o.relationship}]->(p)
    )
  end

  #
  # Format the base attributes and additional attributes
  #
  # @param key String - arbitrary Cypher node ref
  #
  def _base_attrs(key)
    %(
      \t#{key}.region = '#{@region}',
      \t#{key}.service_type = '#{@service}',
      \t#{key}.asset_type = '#{@asset_type}',
      \t#{key}.loader_type = '#{LOADER_TYPE}',
      \t#{_map_attributes(key, @data)}
    ).strip
  end

  #
  # Format the base attributes of the attached (parent) node
  #
  def _merge_base_attrs(service, asset_type, key)
    %(
      \t#{key}.region = '#{@region}',
      \t#{key}.service_type = '#{service}',
      \t#{key}.asset_type = '#{asset_type}',
      \t#{key}.loader_type = '#{LOADER_TYPE}'
    ).strip
  end

  #
  # Return a Cypher formatted attribute hash for every top-level key in a hash
  # e.g. user_data and policy documents
  #
  def _map_attributes(key, struct = @data)
    # only map string values
    hash = struct.to_h.select { |_k, v| v.class == String }

    # filter out fields we don't want or that may have sketchy formatting
    hash.reject! { |x| FILTERED_ATTRIBUTES.include?(x) }

    # return a formatted string
    hash.map { |k, v| "#{key}.#{k} = '#{v}'"}.join(', ')
  end
end

#
# Generic wrapper for loading AWS assets into RedisGragh
#
#
class AwsGraphDbLoader
  LOADER_TYPE = 'aws'.freeze
  FILTERED_ATTRS = [:user_data].freeze

  def initialize(json)
    @service = json.service
    @region = json.region
    @asset_type = json.asset_type
    @name = json.name
    @data = json.resource.data
  end

  # Return Cypher formatted attribute hash for every top-level key in a hash
  def flatten_attributes(key, struct = @data)
    # filter out any non-strings
    hash = struct.to_h.select { |_k, v| v.class == String }

    # filter out fields we don't want or that may have sketchy formatting
    hash.reject! { |x| FILTERED_ATTRS.include?(x) }

    # return a formatted string
    hash.map { |k, v| "#{key}.#{k} = '#{v}'"}.join(', ')
  end

  # Every? resource belongs to a region
  def map_to_region
    puts 'mapping resource to region'
  end

  def map_to_node(_parent_node_type, _parent_node_name)
    puts 'mapping resource to parent resource'
  end

  private

  #
  # Cypher query to create/upsert a node
  #
  def _build_query(node)
    %(
      MERGE (n:#{node} { name: '#{@name}' })
      ON CREATE SET #{_base_attrs('n')}
      ON MATCH SET #{_base_attrs('n')}
    )
  end

  #
  # Cypher query to find an existing node, create/upsert a parent node, and attach a relationship
  #
  # e.g. parent_node == AWS_VPC, child_node == AWS_INSTANCE, relationship == IS_MEMBER_OF
  def _merge_query(opts)
    o = OpenStruct.new(opts)

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
  # TODO: key isn't really needed here
  #
  def _base_attrs(key)
    %(
      \t#{key}.region = '#{@region}',
      \t#{key}.service_type = '#{@service}',
      \t#{key}.asset_type = '#{@asset_type}',
      \t#{key}.loader_type = '#{LOADER_TYPE}',
      \t#{flatten_attributes(key, @data)}
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
end

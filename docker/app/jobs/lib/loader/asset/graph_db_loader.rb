# frozen_string_literal: true

#
# Generic wrapper for loading AWS assets into RedisGragh
#
# Query types:
#     1) upsert: create a new node, maps all top level @data attributes.
#        (e.g. EC2_INSTANCE). Optionally pass an attribute hash with
#        .data to create a new node and map arbitrary top level attributes.
#        (e.g. IAM_MFA_DEVICE).
#     2) upsert_and_link: create a node with no @data attributes, also
#        create a relationship to another node. This assumes a separate
#        `upsert` will populate the rest of the @data fields. (e.g. EC2_INSTANCE
#        ->VPC. Optionally pass .relationship_attributes as a hash to
#        add attributes to the relationship (e.g. EKS_CLUSTER_LOGGING_TYPE).
#        Optionally add .headless = `true` to create a node with no region/type/service
#        fields (e.g. EKS_CLUSTER_LOGGING_TYPE)
#     3) append: add arbitrary fields to an existing node. (e.g. ER_REPOSITORY)
#
# Relationships:
#     When creating relationships, we are using the parent/child taxonomy
#     even though the relationship between nodes is not necessarily that
#     of a parent with a child decendent. The *parent* node is simply the
#     node that is expected to exist before a *child* node can be linked to
#     it via a relationship.
#
class GraphDbLoader
  # only map strings and boolean values
  ACCEPTED_ATTRIBUTES = [Integer, TrueClass, FalseClass, String].freeze
  # TODO: allow :name to be overwritten? (e.g. EKS cluster name)
  # FILTERED_ATTRIBUTES = [:user_data].freeze
  # TODO: filter fields in the service import class instead of here
  FILTERED_ATTRIBUTES = %i[name policy user_data].freeze

  def initialize(json, type = 'aws')
    @account = json.account
    @service = json.service
    @region = json.region
    @asset_type = json.asset_type
    @name = json.name
    @data = json.resource.data
    @loader_type = type
    @last_updated = json.import_id
  end

  private

  #
  # Cypher query to create/match a node
  #
  # e.g.  node = 'AWS_INSTANCE'
  #       id = i-abc123def456 (or full ARN)
  #
  def _merge(opts)
    o = OpenStruct.new(opts)

    raise ApplicationError::GraphLoaderParamsMissing unless o.node && o.id

    %(
      MERGE (n:#{o.node} { name: '#{o.id}', last_updated: #{@last_updated} })
    )
  end

  #
  # Cypher query to create a relationship between two nodes
  #
  #
  def _link(opts)
    o = OpenStruct.new(opts)

    raise ApplicationError::GraphLoaderParamsMissing unless o.from_node &&
                                                            o.from_name &&
                                                            o.to_node &&
                                                            o.to_name &&
                                                            o.relationship

    %(
      MATCH (from:#{o.from_node}),(to:#{o.to_node})
      WHERE from.name = '#{o.from_name}' AND to.name = '#{o.to_name}'
      MERGE (from)-[:#{_relationship_attrs(o)}]->(to)
    ).strip
  end

  #
  # Cypher query to create/upsert a node
  #
  # e.g.  node = 'AWS_INSTANCE'
  #       id = i-abc123def456 (or full ARN)
  #       data == OpenStruct, optional data hash from a custom (nested) node
  #
  def _upsert(opts)
    o = OpenStruct.new(opts)

    raise ApplicationError::GraphLoaderParamsMissing unless o.node && o.id

    %(
      MERGE (n:#{o.node} { name: '#{o.id}' })
      ON CREATE SET #{_base_attrs(o, 'n')}
      ON MATCH SET #{_base_attrs(o, 'n')}
    ).strip
  end

  #
  # Cypher query to find an existing node, create/upsert a child node,
  # and attach a relationship
  #
  # e.g.  parent_node == 'AWS_VPC',
  #       parent_name == parent.arn, (could be a short resource id or a full ARN)
  #       child_node == 'AWS_INSTANCE',
  #       child_name == child.arn, (could be a short resource id or a full ARN)
  #       relationship == 'IS_MEMBER_OF'
  def _upsert_and_link(opts)
    o = OpenStruct.new(opts)

    raise ApplicationError::GraphLoaderParamsMissing unless o.parent_node &&
                                                            o.parent_name &&
                                                            o.child_node &&
                                                            o.child_name &&
                                                            o.relationship

    %(
      MATCH (p:#{o.parent_node} { name: '#{o.parent_name}' })
      MERGE (c:#{o.child_node} { name: '#{o.child_name}' })
      ON CREATE SET #{_merge_base_attrs(o, 'c')}
      ON MATCH SET #{_merge_base_attrs(o, 'c')}
      MERGE (p)-[:#{_relationship_attrs(o)}]->(c)
    ).strip
  end

  #
  # Append node attributes
  #
  # e.g. EKS cluster_logging 'types' as comma separated string or just add more nodes?
  #
  def _append(opts)
    o = OpenStruct.new(opts)

    raise ApplicationError::GraphLoaderParamsMissing unless o.node &&
                                                            o.id &&
                                                            o.data

    %(
      MATCH (x:#{o.node} { name: '#{o.id}' })
      SET #{_map_attributes('x', o.data)}
    ).strip
  end

  #
  # Format the base attributes and additional attributes
  #
  # @param key String - arbitrary Cypher node ref
  #
  def _base_attrs(opts, key)
    # opts.data indicates we are adding a custom node (nested in a top-level resource)
    struct = opts.data || @data

    # last_updated must be an integer
    %(
      \t#{key}.account = '#{@account}',
      \t#{key}.region = '#{@region}',
      \t#{key}.service_type = '#{@service}',
      \t#{key}.asset_type = '#{@asset_type}',
      \t#{key}.loader_type = '#{@loader_type}',
      \t#{key}.last_updated = #{@last_updated},
      \t#{_map_attributes(key, struct)}
    ).strip
  end

  #
  # Format the base attributes of the attached (parent) node
  #
  def _merge_base_attrs(opts, key)
    if opts.headless
      %(
        \t#{key}.headless = 'true'
      ).strip
    else
      # last_updated must be an integer
      %(
        \t#{key}.account = '#{@account}',
        \t#{key}.region = '#{@region}',
        \t#{key}.loader_type = '#{@loader_type}',
        \t#{key}.last_updated = #{@last_updated}
      ).strip
    end
  end

  #
  # Format the relationship details - either with or without attributes
  #
  # @param opts Struct - OpenStruct
  #
  def _relationship_attrs(opts)
    if opts.relationship_attributes

      attrs = opts
              .relationship_attributes
              .map { |k, v| %( #{k}: '#{_esc(v.to_s)}' ) }.join(', ')

      "#{opts.relationship} {#{attrs}, last_updated: #{@last_updated}}"
    else
      "#{opts.relationship} {last_updated: #{@last_updated}}"
    end
  end

  #
  # Return a Cypher formatted attribute hash for every top-level key in a hash
  # e.g. user_data and policy documents
  #
  def _map_attributes(key, struct = @data)
    # binding.pry if @service == 'EKS' && @asset_type == 'cluster'

    # only map strings and boolean values
    # hash = struct.to_h.select { |_k, v| v.is_a?(String) }
    hash = struct.to_h.select { |_k, v| ACCEPTED_ATTRIBUTES.include?(v.class) }

    # filter out fields we don't want or that may have sketchy formatting
    # TODO: filter fields in the service import class instead of here?
    hash.reject! { |k| FILTERED_ATTRIBUTES.include?(k.to_s.underscore.to_sym) }

    # return a formatted string
    hash.map { |k, v| %( #{key}.#{k.to_s.underscore} = '#{_esc(v.to_s)}' ) }.join(', ')
  end

  # TODO: refactor
  def _esc(value)
    value.gsub("'", '"')
  end
end

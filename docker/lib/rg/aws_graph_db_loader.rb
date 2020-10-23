#
# Generic wrapper for loading AWS assets into RedisGragh
#
#
class AwsGraphDbLoader
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

    hash.reject! { |x| FILTERED_ATTRS.include?(x) }

    # return a formatted string
    hash.map { |k, v| "#{key}.#{k} = '#{v}'"}.join(', ')
  end

  # Every? resource belongs to a region
  def map_to_region
    puts 'mapping to region'
  end
end

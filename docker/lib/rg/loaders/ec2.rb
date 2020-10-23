#
# Load EC2 assets into RedisGraph
#
# Load all top-level resources first;
# TODO: map a LIVES_IN/RUNS_IN relationship for each resource to the region
#
class AwsEc2Loader < AwsGraphDbLoader
  # generate Cypher query strings
  # TODO: array of multiple queries?
  def to_q
    return _instance if @asset_type == 'instance'
    return _vpc if @asset_type == 'vpc'
    return _security_group if @asset_type == 'security_group'
    return _network_interface if @asset_type == 'network_interface'
    return _subnet if @asset_type == 'subnet'
    return _address if @asset_type == 'eip_address'
    return _nat_gateway if @asset_type == 'nat_gateway'
    return _route_table if @asset_type == 'route_table'
    return _image if @asset_type == 'image'
    return _snapshot if @asset_type == 'snapshot'
    return _flow_log if @asset_type == 'flow_log'
    return _volume if @asset_type == 'volume'
    return _vpn_gateway if @asset_type == 'vpn_gateway'
    return _vpc_peering_connection if @asset_type == 'peering_connection'
  end

  private

  #
  # Format the base attributes and additional attributes
  #
  # @param key String - arbtrary Cypher node ref
  #
  def _base_attrs(key)
    %(
      \t#{key}.service_type = '#{@service}',
      \t#{key}.asset_type = '#{@asset_type}',
      \t#{key}.loader_type = 'aws',
      \t#{flatten_attributes(key, @data)}
    ).strip
  end

  def _instance
    %(
      MERGE (i:AWS_INSTANCE { name: '#{@name}' })
      ON CREATE SET #{_base_attrs('i')}
      ON MATCH SET #{_base_attrs('i')}
    )
  end

  def _vpc
    %(
      MERGE (v:AWS_VPC { name: '#{@name}' })
      ON CREATE SET #{_base_attrs('v')}
      ON MATCH SET #{_base_attrs('v')}
    )
  end

  def _security_group
    %(
      MERGE (sg:AWS_SECURITY_GROUP { name: '#{@name}' })
      ON CREATE SET #{_base_attrs('sg')}
      ON MATCH SET #{_base_attrs('sg')}
    )
  end

  def _network_interface
    %(
      MERGE (ni:AWS_NETWORK_INTERFACE { name: '#{@name}' })
      ON CREATE SET #{_base_attrs('ni')}
      ON MATCH SET #{_base_attrs('ni')}
    )
  end

  def _subnet
    %(
      MERGE (s:AWS_SUBNET { name: '#{@name}' })
      ON CREATE SET #{_base_attrs('s')}
      ON MATCH SET #{_base_attrs('s')}
    )
  end

  def _address
    %(
      MERGE (ip:AWS_EIP_ADDRESS { name: '#{@name}' })
      ON CREATE SET #{_base_attrs('ip')}
      ON MATCH SET #{_base_attrs('ip')}
    )
  end

  def _nat_gateway
    %(
      MERGE (gw:AWS_NAT_GATEWAY { name: '#{@name}' })
      ON CREATE SET #{_base_attrs('gw')}
      ON MATCH SET #{_base_attrs('gw')}
    )
  end

  def _route_table
    %(
      MERGE (rt:AWS_ROUTE_TABLE { name: '#{@name}' })
      ON CREATE SET #{_base_attrs('rt')}
      ON MATCH SET #{_base_attrs('rt')}
    )
  end

  def _image
    %(
      MERGE (i:AWS_IMAGE { name: '#{@name}' })
      ON CREATE SET #{_base_attrs('i')}
      ON MATCH SET #{_base_attrs('i')}
    )
  end

  def _snapshot
    %(
      MERGE (ss:AWS_SNAPSHOT { name: '#{@name}' })
      ON CREATE SET #{_base_attrs('ss')}
      ON MATCH SET #{_base_attrs('ss')}
    )
  end

  def _flow_log
    %(
      MERGE (fl:AWS_FLOW_LOG { name: '#{@name}' })
      ON CREATE SET #{_base_attrs('fl')}
      ON MATCH SET #{_base_attrs('fl')}
    )
  end

  def _volume
    %(
      MERGE (vo:AWS_VOLUME { name: '#{@name}' })
      ON CREATE SET #{_base_attrs('vo')}
      ON MATCH SET #{_base_attrs('vo')}
    )
  end

  def _vpn_gateway
    %(
      MERGE (vgw:AWS_VPN_GATEWAY { name: '#{@name}' })
      ON CREATE SET #{_base_attrs('vgw')}
      ON MATCH SET #{_base_attrs('vgw')}
    )
  end

  def _vpc_peering_connection
    %(
      MERGE (pcx:AWS_PEERING_CONNECTION { name: '#{@name}' })
      ON CREATE SET #{_base_attrs('pcx')}
      ON MATCH SET #{_base_attrs('pcx')}
    )
  end
end

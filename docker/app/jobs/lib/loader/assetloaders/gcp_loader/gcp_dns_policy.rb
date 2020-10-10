class GCP_DNS_POLICY < GCPLoader

  def initialize(asset, db, import_id)
    super
  end

  def load
    # set defaults
    networks = []
    alt_name_servers = []
    # grab/delete associated networks
    if asset.dig('resource', 'data', 'networks')
      networks = asset.dig('resource', 'data').delete('networks')
    end
    # grab/delete alternative nameservers
    if asset.dig('resource','data','alternativeNameServerConfig','targetNameServers')
      alt_name_servers = asset.dig('resource','data','alternativeNameServerConfig').delete('targetNameServers')
      asset.dig('resource','data').delete('alternativeNameServerConfig')
    end
    # cleanup
    asset.delete('ancestors')

    # prep for updating or creating
    previous_properties_as_null = fetch_current_properties_as_null(@asset_label, @asset_name)
    properties = prepare_properties(asset)
    query = """
      MERGE (a:#{@asset_label} { name: \"#{@asset_name}\" })
      ON CREATE SET a.asset_type = \"#{@asset_type}\", a.last_updated = #{@import_id}, a.loader_type = \"gcp\", #{properties}
      ON MATCH SET #{previous_properties_as_null} a.asset_type = \"#{@asset_type}\", a.last_updated = #{@import_id}, a.loader_type = \"gcp\", #{properties}
    """
    graphquery(query)

    # Relationships to networks
    networks.each do |network|
      compute_network_name = compute_url_to_compute_name(network['networkUrl'])
      query = """
        MATCH (d:#{@asset_label} { name: \"#{@asset_name}\" })
        MERGE (a:GCP_COMPUTE_NETWORK { name: \"#{compute_network_name}\" })
        ON CREATE SET a.asset_type = \"compute.googleapis.com/Network\", a.last_updated = #{@import_id}, a.loader_type = \"gcp\"
        ON MATCH SET a.asset_type = \"compute.googleapis.com/Network\", a.last_updated = #{@import_id}, a.loader_type = \"gcp\"
        MERGE (a)-[:HAS_DNSPOLICY]->(d)
      """
      graphquery(query)
    end
    
    alt_name_servers.each do |alt_name_server|
      query = """
        MATCH (d:#{@asset_label} { name: \"#{@asset_name}\" })
        MERGE (a:GCP_DNS_ALTERNATE_NAME_SERVER { name: \"#{alt_name_server['ipv4Address']}\" })
        ON CREATE SET a.forwardingPath = \"#{alt_name_server['forwardingPath']}\", a.asset_type = \"dns.googleapis.com/AlternativeNameServer\", a.last_updated = #{@import_id}, a.loader_type = \"gcp\"
        ON MATCH SET a.forwardingPath = \"#{alt_name_server['forwardingPath']}\", a.asset_type = \"dns.googleapis.com/AlternativeNameServer\", a.last_updated = #{@import_id}, a.loader_type = \"gcp\"
        MERGE (d)-[:HAS_ALTERNATENAMESERVER]->(a)
      """
      graphquery(query)
    end
  end
end

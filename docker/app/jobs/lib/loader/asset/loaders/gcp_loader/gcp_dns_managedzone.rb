class GCP_DNS_MANAGEDZONE < GCPLoader

  def initialize(asset, db, import_id)
    super
  end

  def load
    # grab/delete name_servers array
    name_servers = []
    if asset.dig('resource', 'data', 'nameServers')
      name_servers = asset.dig('resource', 'data').delete('nameServers')
    end
    # grab/delete visible private networks
    visible_to_networks = []
    if asset.dig('resource', 'data', 'privateVisibilityConfig', 'networks')
      visible_to_networks = asset.dig('resource', 'data', 'privateVisibilityConfig').delete('networks')
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

    # Relationships to internal nameservers
    name_servers.each do |name_server|
      query = """
        MATCH (d:#{@asset_label} { name: \"#{@asset_name}\" })
        MERGE (a:GCP_DNS_NAMESERVER { name: \"#{name_server}\" })
        ON CREATE SET a.asset_type = \"dns.googleapis.com/NameServer\", a.last_updated = #{@import_id}, a.loader_type = \"gcp\"
        ON MATCH SET a.asset_type = \"dns.googleapis.com/NameServer\", a.last_updated = #{@import_id}, a.loader_type = \"gcp\"
        MERGE (d)-[:HAS_DNSNAMESERVER]->(a)
      """
      graphquery(query)
    end

    # Relationships to VPCs
    visible_to_networks.each do |visible_to_network|
      compute_network_name = compute_url_to_compute_name(visible_to_network['networkUrl'])
      query = """
        MATCH (d:#{@asset_label} { name: \"#{@asset_name}\" })
        MERGE (a:GCP_COMPUTE_NETWORK { name: \"#{compute_network_name}\" })
        ON CREATE SET a.asset_type = \"compute.googleapis.com/Network\", a.last_updated = #{@import_id}, a.loader_type = \"gcp\"
        ON MATCH SET a.asset_type = \"compute.googleapis.com/Network\", a.last_updated = #{@import_id}, a.loader_type = \"gcp\"
        MERGE (a)-[:HAS_PRIVATEDNSZONE]->(d)
      """
      graphquery(query)
    end
  end
end

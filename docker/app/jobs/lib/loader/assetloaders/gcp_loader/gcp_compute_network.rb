class GCP_COMPUTE_NETWORK < GCPLoader

  def initialize(asset, db, import_id)
    super
  end

  def load
    # set defaults
    peerings = []
    # grab/delete associated networks
    if asset.dig('resource', 'data', 'peerings')
      peerings = asset.dig('resource', 'data').delete('peerings')
    end
    # grab/delete alternative nameservers
    if asset.dig('resource','data','subnetworks')
      asset.dig('resource','data').delete('subnetworks')
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
    peerings.each do |peering|
      compute_network_name = compute_url_to_compute_name(peering['network'])
      query = """
        MATCH (d:#{@asset_label} { name: \"#{@asset_name}\" })
        MERGE (a:GCP_COMPUTE_NETWORK { name: \"#{compute_network_name}\" })
        ON CREATE SET a.asset_type = \"compute.googleapis.com/Network\", a.last_updated = #{@import_id}, a.loader_type = \"gcp\"
        ON MATCH SET a.asset_type = \"compute.googleapis.com/Network\", a.last_updated = #{@import_id}, a.loader_type = \"gcp\"
        MERGE (d)-[:IS_VPCPEER]->(a)
      """
      graphquery(query)
    end
  end
end

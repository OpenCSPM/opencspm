class GCP_COMPUTE_FIREWALL < GCPLoader

  def initialize(asset, db, import_id)
    super
  end

  def load
    # grab/delete associated networks
    network = asset.dig('resource', 'data').delete('network')
    # cleanup
    if asset.dig('resource','data', 'selfLink')
      location = asset.dig('resource', 'data').delete('selfLink')
    end
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
    compute_network_name = compute_url_to_compute_name(network)
    query = """
      MATCH (s:#{@asset_label} { name: \"#{@asset_name}\" })
      MERGE (a:GCP_COMPUTE_NETWORK { name: \"#{compute_network_name}\" })
      ON CREATE SET a.asset_type = \"compute.googleapis.com/Network\", a.last_updated = #{@import_id}, a.loader_type = \"gcp\"
      ON MATCH SET a.asset_type = \"compute.googleapis.com/Network\", a.last_updated = #{@import_id}, a.loader_type = \"gcp\"
      MERGE (a)-[:HAS_FIREWALL]->(s)
    """
    graphquery(query)
  end
end

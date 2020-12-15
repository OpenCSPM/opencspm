class GCP_COMPUTE_ADDRESS < GCPLoader

  def initialize(asset, db, import_id)
    super
  end

  def load
    # set defaults
    region = asset.dig('resource').delete('location')
    subnetwork = ""
    # grab/delete associated subnetwork
    if asset.dig('resource', 'data', 'subnetwork')
      subnetwork = asset.dig('resource', 'data').delete('subnetwork')
    end

    # cleanup
    if asset.dig('resource','data', 'region')
      asset.dig('resource', 'data').delete('region')
    end
    if asset.dig('resource','data', 'selfLink')
      asset.dig('resource', 'data').delete('selfLink')
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

    unless subnetwork.empty?
      # Relationships to subnetwork
      compute_subnetwork_name = compute_url_to_compute_name(subnetwork)
      query = """
        MATCH (a:#{@asset_label} { name: \"#{@asset_name}\" })
        MERGE (n:GCP_COMPUTE_SUBNETWORK { name: \"#{compute_subnetwork_name}\" })
        ON CREATE SET n.asset_type = \"compute.googleapis.com/Network\", n.last_updated = #{@import_id}, n.loader_type = \"gcp\"
        ON MATCH SET n.asset_type = \"compute.googleapis.com/Network\", n.last_updated = #{@import_id}, n.loader_type = \"gcp\"
        MERGE (n)-[:HAS_ADDRESS]->(a)
      """
      graphquery(query)
    end

    # Relationships to region
    query = """
      MATCH (a:#{@asset_label} { name: \"#{@asset_name}\" })
      MERGE (r:GCP_REGION { name: \"#{region}\" })
      ON CREATE SET r.asset_type = \"compute.googleapis.com/Region\", r.last_updated = #{@import_id}, r.loader_type = \"gcp\"
      ON MATCH SET r.asset_type = \"compute.googleapis.com/Region\", r.last_updated = #{@import_id}, r.loader_type = \"gcp\"
      MERGE (a)-[:IN_REGION]->(r)
    """
    graphquery(query)
  end
end

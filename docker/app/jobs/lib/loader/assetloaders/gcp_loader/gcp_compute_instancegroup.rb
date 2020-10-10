class GCP_COMPUTE_INSTANCEGROUP < GCPLoader

  def initialize(asset, db, import_id)
    super
  end

  def load
    # set defaults
    zone = asset.dig('resource').delete('location')
    # grab/delete subnetwork
    subnetwork = asset.dig('resource', 'data').delete('subnetwork')

    # cleanup
    if asset.dig('resource','data', 'network')
      asset.dig('resource', 'data').delete('network')
    end
    if asset.dig('resource','data', 'zone')
      asset.dig('resource', 'data').delete('zone')
    end
    if asset.dig('resource','data', 'version')
      asset.dig('resource', 'data').delete('version')
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

    compute_subnetwork_name = compute_url_to_compute_name(subnetwork)
    query = """
      MATCH (d:#{@asset_label} { name: \"#{@asset_name}\" })
      MERGE (a:GCP_COMPUTE_SUBNETWORK { name: \"#{compute_subnetwork_name}\" })
      ON CREATE SET a.asset_type = \"compute.googleapis.com/Subnetwork\", a.last_updated = #{@import_id}, a.loader_type = \"gcp\"
      ON MATCH SET a.asset_type = \"compute.googleapis.com/Subnetwork\", a.last_updated = #{@import_id}, a.loader_type = \"gcp\"
      MERGE (d)-[:IN_SUBNETWORK]->(a)
    """
    graphquery(query)

    # Relationship to zone
    query = """
      MATCH (i:#{@asset_label} { name: \"#{@asset_name}\" })
      MERGE (z:GCP_ZONE { name: \"#{zone}\" })
      ON CREATE SET z.asset_type = \"compute.googleapis.com/Zone\", z.last_updated = #{@import_id}, z.loader_type = \"gcp\"
      ON MATCH SET z.asset_type = \"compute.googleapis.com/Zone\", z.last_updated = #{@import_id}, z.loader_type = \"gcp\"
      MERGE (i)-[:IN_ZONE]->(z)
    """
    graphquery(query)
  end
end

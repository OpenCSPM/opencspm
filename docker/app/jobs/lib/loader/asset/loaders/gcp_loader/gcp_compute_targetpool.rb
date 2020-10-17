class GCP_COMPUTE_TARGETPOOL < GCPLoader

  def initialize(asset, db, import_id)
    super
  end

  def load
    # set defaults
    region = asset.dig('resource').delete('location')
    healthchecks = []

    # grab/delete associated healthchecks
    if asset.dig('resource', 'data', 'healthChecks')
      healthchecks = asset.dig('resource', 'data').delete('healthChecks')
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

    healthchecks.each do |hc|
      # Relationships to healthchecks
      compute_hc_name = compute_url_to_compute_name(hc)
      query = """
        MATCH (f:#{@asset_label} { name: \"#{@asset_name}\" })
        MERGE (h:GCP_COMPUTE_HTTPHEALTHCHECK { name: \"#{compute_hc_name}\" })
        ON CREATE SET h.asset_type = \"compute.googleapis.com/HttpHealthCheck\", h.last_updated = #{@import_id}, h.loader_type = \"gcp\"
        ON MATCH SET h.asset_type = \"compute.googleapis.com/HttpHealthCheck\", h.last_updated = #{@import_id}, h.loader_type = \"gcp\"
        MERGE (f)-[:HAS_HEALTHCHECK]->(h)
      """
      graphquery(query)
    end

    # Relationships to region
    query = """
      MATCH (t:#{@asset_label} { name: \"#{@asset_name}\" })
      MERGE (r:GCP_REGION { name: \"#{region}\" })
      ON CREATE SET r.asset_type = \"compute.googleapis.com/Region\", r.last_updated = #{@import_id}, r.loader_type = \"gcp\"
      ON MATCH SET r.asset_type = \"compute.googleapis.com/Region\", r.last_updated = #{@import_id}, r.loader_type = \"gcp\"
      MERGE (t)-[:IN_REGION]->(r)
    """
    graphquery(query)
  end
end

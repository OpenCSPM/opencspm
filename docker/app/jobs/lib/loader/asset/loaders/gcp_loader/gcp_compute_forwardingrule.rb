class GCP_COMPUTE_FORWARDINGRULE < GCPLoader

  def initialize(asset, db, import_id)
    super
  end

  def load
    # set defaults
    region = asset.dig('resource').delete('location')
    target = ""

    # grab/delete associated targetpool
    if asset.dig('resource', 'data', 'target')
      target = asset.dig('resource', 'data').delete('target')
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

    unless target.empty?
      # Relationships to target
      compute_target_name = compute_url_to_compute_name(target)
      query = """
        MATCH (f:#{@asset_label} { name: \"#{@asset_name}\" })
        MERGE (t:GCP_COMPUTE_TARGETPOOL { name: \"#{compute_target_name}\" })
        ON CREATE SET t.asset_type = \"compute.googleapis.com/TargetPool\", t.last_updated = #{@import_id}, t.loader_type = \"gcp\"
        ON MATCH SET t.asset_type = \"compute.googleapis.com/TargetPool\", t.last_updated = #{@import_id}, t.loader_type = \"gcp\"
        MERGE (f)-[:HAS_TARGET]->(t)
      """
      graphquery(query)
    else
      # TODO: Backend Service
    end

    # Relationships to region
    query = """
      MATCH (f:#{@asset_label} { name: \"#{@asset_name}\" })
      MERGE (r:GCP_REGION { name: \"#{region}\" })
      ON CREATE SET r.asset_type = \"compute.googleapis.com/Region\", r.last_updated = #{@import_id}, r.loader_type = \"gcp\"
      ON MATCH SET r.asset_type = \"compute.googleapis.com/Region\", r.last_updated = #{@import_id}, r.loader_type = \"gcp\"
      MERGE (f)-[:IN_REGION]->(r)
    """
    graphquery(query)
  end
end

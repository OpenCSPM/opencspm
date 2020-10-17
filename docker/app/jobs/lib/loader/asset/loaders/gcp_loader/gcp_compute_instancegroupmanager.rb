class GCP_COMPUTE_INSTANCEGROUPMANAGER < GCPLoader

  def initialize(asset, db, import_id)
    super
  end

  def load
    # set defaults
    instancegroup = asset.dig('resource','data').delete('instanceGroup')
    instancetemplate = asset.dig('resource','data').delete('instanceTemplate')
    zone = asset.dig('resource').delete('location')

    # cleanup
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

    compute_ig_name = compute_url_to_compute_name(instancegroup)
    query = """
      MATCH (d:#{@asset_label} { name: \"#{@asset_name}\" })
      MERGE (a:GCP_COMPUTE_INSTANCEGROUP { name: \"#{compute_ig_name}\" })
      ON CREATE SET a.asset_type = \"compute.googleapis.com/InstanceGroup\", a.last_updated = #{@import_id}, a.loader_type = \"gcp\"
      ON MATCH SET a.asset_type = \"compute.googleapis.com/InstanceGroup\", a.last_updated = #{@import_id}, a.loader_type = \"gcp\"
      MERGE (d)-[:HAS_INSTANCEGROUP]->(a)
    """
    graphquery(query)

    compute_it_name = compute_url_to_compute_name(instancetemplate)
    query = """
      MATCH (d:#{@asset_label} { name: \"#{@asset_name}\" })
      MERGE (a:GCP_COMPUTE_INSTANCETEMPLATE { name: \"#{compute_it_name}\" })
      ON CREATE SET a.asset_type = \"compute.googleapis.com/InstanceTemplate\", a.last_updated = #{@import_id}, a.loader_type = \"gcp\"
      ON MATCH SET a.asset_type = \"compute.googleapis.com/InstanceTemplate\", a.last_updated = #{@import_id}, a.loader_type = \"gcp\"
      MERGE (d)-[:HAS_INSTANCETEMPLATE]->(a)
    """
    graphquery(query)

    # Relationships to region
    query = """
      MATCH (t:#{@asset_label} { name: \"#{@asset_name}\" })
      MERGE (z:GCP_ZONE { name: \"#{zone}\" })
      ON CREATE SET z.asset_type = \"compute.googleapis.com/Zone\", z.last_updated = #{@import_id}, z.loader_type = \"gcp\"
      ON MATCH SET z.asset_type = \"compute.googleapis.com/Zone\", z.last_updated = #{@import_id}, z.loader_type = \"gcp\"
      MERGE (t)-[:IN_ZONE]->(z)
    """
    graphquery(query)
  end
end

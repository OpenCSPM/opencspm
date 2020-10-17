class GCP_COMPUTE_DISK < GCPLoader

  def initialize(asset, db, import_id)
    super
  end

  def load
    licenses = []
    if asset.dig('resource','data', 'licenses')
      licenses = asset.dig('resource', 'data').delete('licenses')
    end
    guestosfeatures = []
    if asset.dig('resource','data', 'guestOsFeatures')
      guestosfeatures = asset.dig('resource', 'data').delete('guestOsFeatures')
    end
    users = []
    if asset.dig('resource','data', 'users')
      users = asset.dig('resource', 'data').delete('users')
    end
    
    zone = "global" 
    if asset.dig('resource','data', 'zone')
      zone = asset.dig('resource', 'data').delete('zone')
    end
    # cleanup
    if asset.dig('resource','data', 'selfLink')
      asset.dig('resource', 'data').delete('selfLink')
    end
    if asset.dig('resource','data', 'licenseCodes')
      asset.dig('resource', 'data').delete('licenseCodes')
    end
    asset.delete('ancestors')

    # prep for updating or creating
    previous_properties_as_null = fetch_current_properties_as_null(@asset_label, @asset_name)
    properties = prepare_properties(asset)
    query = """
      MERGE (a:#{@asset_label} { name: \"#{@asset_name}\" })
      ON CREATE SET a.asset_type = \"#{@asset_type}\",
                    a.last_updated = #{@import_id},
                    a.loader_type = \"gcp\",
                    #{properties}
      ON MATCH SET  #{previous_properties_as_null}
                    a.asset_type = \"#{@asset_type}\",
                    a.last_updated = #{@import_id},
                    a.loader_type = \"gcp\",
                    #{properties}
    """
    graphquery(query)

    # (GCP_COMPUTE_INSTANCE)-[:HAS_DISK]->(GCP_COMPUTE_DISK)
    # Attached to instance
    users.each do |user_instance|
      instance_name = compute_url_to_compute_name(user_instance)
      query = """
        MATCH (t:#{@asset_label} { name: \"#{@asset_name}\" })
        MERGE (a:GCP_COMPUTE_INSTANCE { name: \"#{instance_name}\" })
        ON CREATE SET a.asset_type = \"compute.googleapis.com/Instance\",
                      a.last_updated = #{@import_id},
                      a.loader_type = \"gcp\"
        ON MATCH SET  a.asset_type = \"compute.googleapis.com/Instance\",
                      a.last_updated = #{@import_id},
                      a.loader_type = \"gcp\"
        MERGE (a)-[:HAS_DISK]->(t)
      """
      graphquery(query)
    end

    # guestOsFeatures
    guestosfeatures.each do |gof|
      gof_name = gof['type']
      query = """
        MATCH (t:#{@asset_label} { name: \"#{@asset_name}\" })
        MERGE (a:GCP_COMPUTE_GUESTOSFEATURE { name: \"#{gof_name}\" })
        ON CREATE SET a.asset_type = \"compute.googleapis.com/DiskGuestOsFeature\",
                      a.last_updated = #{@import_id},
                      a.loader_type = \"gcp\"
        ON MATCH SET  a.asset_type = \"compute.googleapis.com/DiskGuestOsFeature\",
                      a.last_updated = #{@import_id},
                      a.loader_type = \"gcp\"
        MERGE (t)-[:HAS_GUESTOSFEATURE]->(a)
      """
      graphquery(query)
    end

    # licenseCodes
    licenses.each do |lc|
      # -[:HAS_LICENSE]->(GCP_COMPUTE_DISKLICENSE)
      query = """
        MATCH (t:#{@asset_label} { name: \"#{@asset_name}\" })
        MERGE (a:GCP_COMPUTE_DISKLICENSE { name: \"#{lc}\" })
        ON CREATE SET a.asset_type = \"compute.googleapis.com/DiskLicense\",
                      a.last_updated = #{@import_id},
                      a.loader_type = \"gcp\"
        ON MATCH SET  a.asset_type = \"compute.googleapis.com/DiskLicense\",
                      a.last_updated = #{@import_id},
                      a.loader_type = \"gcp\"
        MERGE (t)-[:HAS_DISKLICENSE]->(a)
      """
      graphquery(query)
    end

    # Relationship to zone
    query = """
      MATCH (d:#{@asset_label} { name: \"#{@asset_name}\" })
      MERGE (z:GCP_ZONE { name: \"#{zone}\" })
      ON CREATE SET z.asset_type = \"compute.googleapis.com/Zone\",
                    z.last_updated = #{@import_id},
                    z.loader_type = \"gcp\"
      ON MATCH SET  z.asset_type = \"compute.googleapis.com/Zone\",
                    z.last_updated = #{@import_id},
                    z.loader_type = \"gcp\"
      MERGE (d)-[:IN_ZONE]->(z)
    """
    graphquery(query)

  end
end

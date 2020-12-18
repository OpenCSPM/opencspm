class GCP_CONTAINER_CLUSTER < GCPLoader

  def initialize(asset, db, import_id)
    super
  end

  def load
    # set defaults
    zones = asset.dig('resource','data').delete('locations')
    # grab/delete subnetwork
    subnetwork = asset.dig('resource', 'data','networkConfig').delete('subnetwork')
    nodepools = asset.dig('resource', 'data').delete('nodePools')
    master_auth_networks = []
    if asset.dig('resource','data', 'masterAuthorizedNetworksConfig','cidrBlocks')
      master_auth_networks = asset.dig('resource','data', 'masterAuthorizedNetworksConfig').delete('cidrBlocks')
    end
    if asset.dig('resource','data', 'instanceGroupUrls')
      asset.dig('resource','data').delete('instanceGroupUrls')
    end

    # cleanup
    if asset.dig('resource','data', 'instanceGroupUrls')
      asset.dig('resource', 'data').delete('instanceGroupUrls')
    end
    if asset.dig('resource','data', 'zone')
      asset.dig('resource', 'data').delete('zone')
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

    # Subnetwork
    compute_subnetwork_name = "compute.googleapis.com/#{subnetwork}"
    query = """
      MATCH (c:#{@asset_label} { name: \"#{@asset_name}\" })
      MERGE (a:GCP_COMPUTE_SUBNETWORK { name: \"#{compute_subnetwork_name}\" })
      ON CREATE SET a.asset_type = \"compute.googleapis.com/Subnetwork\",
                    a.last_updated = #{@import_id},
                    a.loader_type = \"gcp\"
      ON MATCH SET  a.asset_type = \"compute.googleapis.com/Subnetwork\",
                    a.last_updated = #{@import_id},
                    a.loader_type = \"gcp\"
      MERGE (c)-[:IN_SUBNETWORK]->(a)
    """
    graphquery(query)

    # Relationships to zone
    zones.each do |zone|
      query = """
        MATCH (c:#{@asset_label} { name: \"#{@asset_name}\" })
        MERGE (z:GCP_ZONE { name: \"#{zone}\" })
        ON CREATE SET z.asset_type = \"compute.googleapis.com/Zone\",
                      z.last_updated = #{@import_id},
                      z.loader_type = \"gcp\"
        ON MATCH SET  z.asset_type = \"compute.googleapis.com/Zone\",
                      z.last_updated = #{@import_id},
                      z.loader_type = \"gcp\"
        MERGE (c)-[:IN_ZONE]->(z)
      """
      graphquery(query)
    end

    # Master Authorized Networks
    master_auth_networks.each do |master_auth_network|
      network_name = "#{master_auth_network['displayName']}_#{master_auth_network['cidrBlock']}"
      query = """
        MATCH (c:#{@asset_label} { name: \"#{@asset_name}\" })
        MERGE (m:GCP_CONTAINER_MASTERAUTHORIZEDNETWORK { name: \"#{network_name}\" })
        ON CREATE SET m.asset_type = \"container.googleapis.com/MasterAuthorizedNetwork\",
                      m.cidr_block = \"#{master_auth_network['cidrBlock']}\",
                      m.display_name = \"#{master_auth_network['displayName']}\",
                      m.last_updated = #{@import_id},
                      m.loader_type = \"gcp\"
        ON MATCH SET m.asset_type = \"container.googleapis.com/MasterAuthorizedNetwork\",
                      m.cidrBlock = \"#{master_auth_network['cidrBlock']}\",
                      m.displayName = \"#{master_auth_network['displayName']}\",
                      m.last_updated = #{@import_id},
                      m.loader_type = \"gcp\"
        MERGE (c)-[:HAS_MASTERAUTHORIZEDNETWORK]->(m)
      """
      graphquery(query)
    end

    nodepools.each do |nodepool|
      network_tags = []
      if nodepool.dig('config','tags')
        network_tags = nodepool.dig('config').delete('tags')
      end
      instance_groups = []
      if nodepool.dig('instanceGroupUrls')
        instance_groups = nodepool.delete('instanceGroupUrls')
      end
      oauth_scopes = []
      if nodepool.dig('config','oauthScopes')
        oauth_scopes = nodepool.dig('config').delete('oauthScopes')
      end
      zones = []
      if nodepool.dig('locations')
        zones = nodepool.delete('locations')
      end
      nodepool_name = compute_url_to_compute_name(nodepool['selfLink'])

      previous_properties_as_null = fetch_current_properties_as_null('GCP_CONTAINER_NODEPOOL', nodepool_name)
      properties = prepare_properties(nodepool)

      query = """
        MATCH (c:#{@asset_label} { name: \"#{@asset_name}\" })
        MERGE (a:GCP_CONTAINER_NODEPOOL { name: \"#{nodepool_name}\" })
        ON CREATE SET a.asset_type = \"container.googleapis.com/NodePool\",
                      a.last_updated = #{@import_id},
                      a.loader_type = \"gcp\",
                      #{properties}
        ON MATCH SET  #{previous_properties_as_null} 
                      a.asset_type = \"container.googleapis.com/NodePool\",
                      a.last_updated = #{@import_id},
                      a.loader_type = \"gcp\",
                      #{properties}
        MERGE (c)-[:HAS_NODEPOOL]->(a)
      """
      graphquery(query)

      # config.oauthscopes
      oauth_scopes.each do |scope|
        query = """
          MATCH (n:GCP_CONTAINER_NODEPOOL { name: \"#{nodepool_name}\" })
          MERGE (s:GCP_IAM_OAUTHSCOPE { name: \"#{scope}\" })
          ON CREATE SET s.asset_type = \"iam.googleapis.com/OAuthScope\",
                        s.last_updated = #{@import_id},
                        s.loader_type = \"gcp\"
          ON MATCH SET  s.asset_type = \"iam.googleapis.com/OAuthScope\",
                        s.last_updated = #{@import_id},
                        s.loader_type = \"gcp\"
          MERGE (n)-[:HAS_OAUTHSCOPE]->(s)
        """
        graphquery(query)
      end

      # Attached ServiceAccount
      service_account = nodepool.dig('config').delete('serviceAccount')
      query = """
        MATCH (n:GCP_CONTAINER_NODEPOOL { name: \"#{nodepool_name}\" })
        MERGE (s:GCP_IDENTITY { name: \"serviceAccount:#{service_account}\" })
        ON CREATE SET s.asset_type = \"iam.googleapis.com/ServiceAccount\",
                      s.member_type = \"serviceAccount\",
                      s.member_name = \"#{service_account}\",
                      s.last_updated = #{@import_id},
                      s.loader_type = \"gcp\"
        ON MATCH SET  s.asset_type = \"iam.googleapis.com/ServiceAccount\",
                      s.member_type = \"serviceAccount\",
                      s.member_name = \"#{service_account}\",
                      s.last_updated = #{@import_id},
                      s.loader_type = \"gcp\"
        MERGE (n)-[:HAS_SERVICEACCOUNT]->(s)
      """
      graphquery(query)

      # config.tags
      network_tags.each do |network_tag|
        query = """
          MATCH (n:GCP_CONTAINER_NODEPOOL { name: \"#{nodepool_name}\" })
          MERGE (t:GCP_COMPUTE_NETWORKTAG { name: \"#{network_tag}\" })
          ON CREATE SET t.asset_type = \"compute.googleapis.com/NetworkTag\",
                        t.last_updated = #{@import_id},
                        t.loader_type = \"gcp\"
          ON MATCH SET  t.asset_type = \"compute.googleapis.com/NetworkTag\",
                        t.last_updated = #{@import_id},
                        t.loader_type = \"gcp\"
          MERGE (n)-[:HAS_NETWORKTAG]->(t)
        """
        graphquery(query)
      end

      # instancegroupurls
      instance_groups.each do |ig|
        ig_name = compute_url_to_compute_name(ig)
        query = """
          MATCH (n:GCP_CONTAINER_NODEPOOL { name: \"#{nodepool_name}\" })
          MERGE (t:GCP_COMPUTE_INSTANCEGROUPMANAGER { name: \"#{ig_name}\" })
          ON CREATE SET t.asset_type = \"compute.googleapis.com/InstanceGroupManager\",
                        t.last_updated = #{@import_id},
                        t.loader_type = \"gcp\"
          ON MATCH SET  t.asset_type = \"compute.googleapis.com/InstanceGroupManager\",
                        t.last_updated = #{@import_id},
                        t.loader_type = \"gcp\"
          MERGE (n)-[:HAS_INSTANCEGROUPMANAGER]->(t)
        """
        graphquery(query)
      end

      # locations = zones
      zones.each do |zone|
        query = """
          MATCH (n:GCP_CONTAINER_NODEPOOL { name: \"#{nodepool_name}\" })
          MERGE (z:GCP_ZONE { name: \"#{zone}\" })
          ON CREATE SET z.asset_type = \"compute.googleapis.com/Zone\",
                        z.last_updated = #{@import_id},
                        z.loader_type = \"gcp\"
          ON MATCH SET  z.asset_type = \"compute.googleapis.com/Zone\",
                        z.last_updated = #{@import_id},
                        z.loader_type = \"gcp\"
          MERGE (n)-[:IN_ZONE]->(z)
        """
        graphquery(query)
      end

    end
  end
end

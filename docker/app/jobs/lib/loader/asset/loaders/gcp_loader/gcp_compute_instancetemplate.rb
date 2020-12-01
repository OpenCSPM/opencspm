class GCP_COMPUTE_INSTANCETEMPLATE < GCPLoader

  def initialize(asset, db, import_id)
    super
  end

  def load
    # set defaults
    disks = []
    if asset.dig('resource','data','properties','disks')
      disks = asset.dig('resource','data','properties').delete('disks')
    end
    nics = [] 
    if asset.dig('resource','data','properties','networkInterface')
      nics = asset.dig('resource','data','properties').delete('networkInterface')
    end
    service_accounts = []
    if asset.dig('resource','data','properties','serviceAccounts')
      service_accounts = asset.dig('resource','data','properties').delete('serviceAccounts')
    end
    network_tags = []
    if asset.dig('resource','data','properties','tags')
      tags = asset.dig('resource','data','properties').delete('tags')
      if tags.dig('items')
        network_tags = tags.dig('items')
      end
    end

    # cleanup
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

    disks.each do |disk|
      disk_name = @asset_name + "/diskTemplate/#{disk['deviceName']}"
      # -[:HAS_DISKTEMPLATE]->(GCP_COMPUTE_DISKTEMPLATE)
      previous_properties_as_null = fetch_current_properties_as_null('GCP_COMPUTE_DISKTEMPLATE', disk_name)
      properties = prepare_properties(disk)
      query = """
        MATCH (t:#{@asset_label} { name: \"#{@asset_name}\" })
        MERGE (a:GCP_COMPUTE_DISKTEMPLATE { name: \"#{disk_name}\" })
        ON CREATE SET a.asset_type = \"compute.googleapis.com/DiskTemplate\",
                      a.last_updated = #{@import_id},
                      a.loader_type = \"gcp\",
                      #{properties}
        ON MATCH SET  #{previous_properties_as_null}
                      a.asset_type = \"compute.googleapis.com/DiskTemplate\",
                      a.last_updated = #{@import_id},
                      a.loader_type = \"gcp\",
                      #{properties}
        MERGE (t)-[:HAS_DISKTEMPLATE]->(a)
      """
      graphquery(query)
    end

    nics.each do |nic|
      access_configs = []
      if nic.dig('accessConfigs')
        access_configs = nic.dig('accessConfigs')
      end
      access_configs.each do |access_config|
        access_config_name = @asset_name + "/accessConfig/#{access_config['name']}"
        previous_properties_as_null = fetch_current_properties_as_null('GCP_COMPUTE_NETWORKACCESSCONFIG', access_config_name)
        properties = prepare_properties(access_config)
        query = """
          MATCH (t:#{@asset_label} { name: \"#{@asset_name}\" })
          MERGE (a:GCP_COMPUTE_NETWORKACCESSCONFIG { name: \"#{access_config_name}\" })
          ON CREATE SET a.asset_type = \"compute.googleapis.com/NetworkAccessConfig\",
                        a.last_updated = #{@import_id},
                        a.loader_type = \"gcp\",
                        #{properties}
          ON MATCH SET  #{previous_properties_as_null}
                        a.asset_type = \"compute.googleapis.com/NetworkAccessConfig\",
                        a.last_updated = #{@import_id},
                        a.loader_type = \"gcp\",
                        #{properties}
          MERGE (t)-[:HAS_NETWORKACCESSCONFIG]->(a)
        """
        graphquery(query)
      end

      alias_ranges = []
      if nic.dig('aliasIpRanges')
        alias_ranges = nic.dig('aliasIpRanges')
      end
      alias_ranges.each do |alias_range|
        alias_range_name = @asset_name + "/aliasRange/#{alias_range['subnetworkRangeName']}"
        previous_properties_as_null = fetch_current_properties_as_null('GCP_COMPUTE_SUBNETWORKALIASRANGE', alias_range_name)
        properties = prepare_properties(alias_range)
        query = """
          MATCH (t:#{@asset_label} { name: \"#{@asset_name}\" })
          MERGE (a:GCP_COMPUTE_SUBNETWORKALIASRANGE { name: \"#{alias_range_name}\" })
          ON CREATE SET a.asset_type = \"compute.googleapis.com/SubnetworkAliasRange\",
                        a.last_updated = #{@import_id},
                        a.loader_type = \"gcp\",
                        #{properties}
          ON MATCH SET  #{previous_properties_as_null}
                        a.asset_type = \"compute.googleapis.com/SubnetworkAliasRange\",
                        a.last_updated = #{@import_id},
                        a.loader_type = \"gcp\",
                        #{properties}
          MERGE (t)-[:HAS_NETWORKALIASRANGE]->(a)
        """
        graphquery(query)
      end

      subnetwork = nic.delete('subnetwork')
      subnetwork_name = compute_url_to_compute_name(subnetwork)
      query = """
        MATCH (t:#{@asset_label} { name: \"#{@asset_name}\" })
        MERGE (a:GCP_COMPUTE_SUBNETWORK { name: \"#{subnetwork_name}\" })
        ON CREATE SET a.asset_type = \"compute.googleapis.com/Subnetwork\",
                      a.last_updated = #{@import_id},
                      a.loader_type = \"gcp\"
        ON MATCH SET  a.asset_type = \"compute.googleapis.com/Subnetwork\",
                      a.last_updated = #{@import_id},
                      a.loader_type = \"gcp\"
        MERGE (t)-[:IN_SUBNETWORK]->(a)
      """
      graphquery(query)

    end

    service_accounts.each do |sa|
      # Attached ServiceAccount
      service_account = sa.dig('email')
      query = """
        MATCH (t:#{@asset_label} { name: \"#{@asset_name}\" })
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
        MERGE (t)-[:HAS_SERVICEACCOUNT]->(s)
      """
      graphquery(query)

      scopes = []
      if sa.dig('scopes')
        scopes = sa.dig('scopes')
      end
      scopes.each do |scope|
        query = """
          MATCH (t:#{@asset_label} { name: \"#{@asset_name}\" })
          MERGE (s:GCP_IAM_OAUTHSCOPE { name: \"#{scope}\" })
          ON CREATE SET s.asset_type = \"iam.googleapis.com/OAuthScope\",
                        s.last_updated = #{@import_id},
                        s.loader_type = \"gcp\"
          ON MATCH SET  s.asset_type = \"iam.googleapis.com/OAuthScope\",
                        s.last_updated = #{@import_id},
                        s.loader_type = \"gcp\"
          MERGE (t)-[:HAS_OAUTHSCOPE]->(s)
        """
        graphquery(query)
      end
    end

    network_tags.each do |network_tag|
      query = """
        MATCH (i:#{@asset_label} { name: \"#{@asset_name}\" })
        MERGE (t:GCP_COMPUTE_NETWORKTAG { name: \"#{network_tag}\" })
        ON CREATE SET t.asset_type = \"compute.googleapis.com/NetworkTag\",
                      t.last_updated = #{@import_id},
                      t.loader_type = \"gcp\"
        ON MATCH SET  t.asset_type = \"compute.googleapis.com/NetworkTag\",
                      t.last_updated = #{@import_id},
                      t.loader_type = \"gcp\"
        MERGE (i)-[:HAS_NETWORKTAG]->(t)
      """
      graphquery(query)
    end

  end
end

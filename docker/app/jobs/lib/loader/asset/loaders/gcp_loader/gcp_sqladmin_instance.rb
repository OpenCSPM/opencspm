class GCP_SQLADMIN_INSTANCE < GCPLoader

  def initialize(asset, db, import_id)
    super
  end

  def load
    # grab/delete visible private networks
    dbflags = []
    if asset.dig('resource', 'data', 'settings', 'databaseFlags')
      dbflags = asset.dig('resource', 'data', 'settings').delete('databaseFlags')
    end
    master_auth_networks = []
    if asset.dig('resource','data', 'settings','ipConfiguration', 'authorizedNetworks')
      master_auth_networks = asset.dig('resource','data', 'settings', 'ipConfiguration').delete('authorizedNetworks')
    end
    # Remove ancestors
    asset.delete('ancestors')

    # create/update gcp asset
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

    # child relationship to dbflag
    dbflags.each do |dbflag|
      dbflag_setting_name = dbflag['name']
      dbflag_setting_value = dbflag['value'] || "none"
      query = """
        MATCH (s:#{@asset_label} { name: \"#{@asset_name}\" })
        MERGE (a:GCP_SQLADMIN_DBFLAG { name: \"#{dbflag_setting_name}\" })
        ON CREATE SET a.asset_type = \"sqladmin.googleapis.com/DatabaseFlag\", a.last_updated = #{@import_id}, a.loader_type = \"gcp\"
        ON MATCH SET a.asset_type = \"sqladmin.googleapis.com/DatabaseFlag\", a.last_updated = #{@import_id}, a.loader_type = \"gcp\"
        MERGE (s)-[:HAS_SQLADMIN_DBFLAG { setting_value: \"#{dbflag_setting_value}\"}]->(a)
      """
      graphquery(query)
    end

    # Master Authorized Networks
    master_auth_networks.each do |master_auth_network|
      network_name = "#{master_auth_network['name']}_#{master_auth_network['value']}"
      query = """
        MATCH (s:#{@asset_label} { name: \"#{@asset_name}\" })
        MERGE (m:GCP_SQLADMIN_MASTERAUTHORIZEDNETWORK { name: \"#{network_name}\" })
        ON CREATE SET m.asset_type = \"sqladmin.googleapis.com/MasterAuthorizedNetwork\",
                      m.cidr_block = \"#{master_auth_network['value']}\",
                      m.last_updated = #{@import_id},
                      m.loader_type = \"gcp\"
        ON MATCH SET m.asset_type = \"sqladmin.googleapis.com/MasterAuthorizedNetwork\",
                      m.cidrBlock = \"#{master_auth_network['value']}\",
                      m.last_updated = #{@import_id},
                      m.loader_type = \"gcp\"
        MERGE (s)-[:HAS_SQLMASTERAUTHORIZEDNETWORK]->(m)
      """
      graphquery(query)
    end
  end
end

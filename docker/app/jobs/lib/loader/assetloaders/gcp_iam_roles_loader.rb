class GCPIAMRolesLoader < AssetLoader

  attr_reader :asset, :import_id, :db

  def initialize(asset, db, import_id)
    @asset = asset
    @db = db
    @import_id = import_id

    load
  end

  def load
    asset_name = sanitize_value(asset['name'])
    asset_type = sanitize_value(asset['asset_type'])

    # Create IAMRole
    query = """
      MERGE (a:GCP_IAM_IAMROLE { name: \"#{asset_name}\" })
      ON CREATE set a.name = \"#{asset_name}\",
                    a.type = 'gcp',
                    a.stage = \"#{asset['stage']}\",
                    a.title = \"#{asset['title']}\",
                    a.description = \"#{asset['description']}\",
                    a.last_updated = #{import_id},
                    a.loader_type = 'gcp'
      ON MATCH  set a.name = \"#{asset_name}\",
                    a.type = 'gcp',
                    a.stage = \"#{asset['stage']}\",
                    a.title = \"#{asset['title']}\",
                    a.description = \"#{asset['description']}\",
                    a.last_updated = #{import_id},
                    a.loader_type = 'gcp'
    """
    graphquery(query)

    return unless asset['includedPermissions'].is_a?(Array)
    # Loop over attached permissions and create/bind them to the above IAM Role
    asset['includedPermissions'].each do |perm_name|
      perm_score = 1
      case perm_name
      when /list$/
        perm_score = 5
      when /create$/
        perm_score = 50
      when /delete$/
        perm_score = 100
      when /actAs$/
        perm_score = 500
      end

      # Create IAMPermission
      query = """
        MATCH (i:GCP_IAM_IAMROLE { name: \"#{asset_name}\" })
        MERGE (a:GCP_IAM_PERMISSION { name: \"#{perm_name}\" })
        ON CREATE set a.name = \"#{perm_name}\",
                      a.score = #{perm_score},
                      a.last_updated = #{import_id},
                      a.loader_type = 'gcp'
        ON MATCH  set a.name = \"#{perm_name}\",
                      a.score = #{perm_score},
                      a.last_updated = #{import_id},
                      a.loader_type = 'gcp'
        MERGE (i)-[:HAS_PERMISSION {last_updated: #{import_id},
                                    loader_type: 'gcp'
                                   }]->(a)
      """
      graphquery(query)
    end
  end
end

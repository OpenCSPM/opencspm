# frozen-string-literal: true

# comment
class GCPIAMRolesLoader < GCPLoader
  attr_reader :asset, :import_id, :db

  def initialize(asset, db, import_id)
    @asset = asset
    @db = db
    @import_id = import_id

    load
  end

  def load
    asset_name = sanitize_value(asset['name'])

    # Create IAMRole
    graphquery(create_iam_role(asset_name, asset, import_id))

    return unless asset['includedPermissions'].is_a?(Array)

    # Loop over attached permissions and create/bind them to the above IAM Role
    asset['includedPermissions'].each do |perm_name|
      # Create IAMPermission
      graphquery(associate_iam_permission(asset_name, perm_name, import_id))
    end
  end

  private

  def calc_perm_score(perm_name)
    perm_score = 1
    case perm_name
    when /list$/ then perm_score = 5
    when /create$/ then perm_score = 50
    when /delete$/ then perm_score = 100
    when /setIamPolicy$/ then perm_score = 500
    when /actAs$/ then perm_score = 500
    end
    perm_score
  end

  def create_iam_role(asset_name, asset, import_id)
    """MERGE (a:GCP_IAM_ROLE { name: \"#{asset_name}\" })
    ON CREATE set a.name = \"#{asset_name}\",
                  a.stage = \"#{asset['stage']}\", a.title = \"#{asset['title']}\",
                  a.description = \"#{asset['description']}\", a.last_updated = #{import_id},
                  a.type = 'gcp', a.loader_type = 'gcp'
    ON MATCH  set a.name = \"#{asset_name}\",
                  a.stage = \"#{asset['stage']}\", a.title = \"#{asset['title']}\",
                  a.description = \"#{asset['description']}\", a.last_updated = #{import_id},
                  a.type = 'gcp', a.loader_type = 'gcp'
    """
  end

  def associate_iam_permission(asset_name, perm_name, import_id)
    # Get permission score
    perm_score = calc_perm_score(perm_name)

    """
      MATCH (i:GCP_IAM_ROLE { name: \"#{asset_name}\" })
      MERGE (a:GCP_IAM_PERMISSION { name: \"#{perm_name}\" })
      ON CREATE set a.name = \"#{perm_name}\", a.score = #{perm_score},
                    a.last_updated = #{import_id}, a.loader_type = 'gcp'
      ON MATCH  set a.name = \"#{perm_name}\", a.score = #{perm_score},
                    a.last_updated = #{import_id}, a.loader_type = 'gcp'
      MERGE (i)-[:HAS_PERMISSION {last_updated: #{import_id}, loader_type: 'gcp' }]->(a)
    """
  end
end

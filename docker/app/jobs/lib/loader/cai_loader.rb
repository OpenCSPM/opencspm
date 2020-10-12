require 'validator/cai'
require 'redisgraph'
require 'db/redisgraph'
require 'loader/asset_loader'
Dir["./app/jobs/lib/loader/assetloaders/*loader.rb"].each {|file| require file }
Dir["./app/jobs/lib/loader/assetloaders/*_loader/*.rb"].each {|file| require file }

class CAILoader

  include Validator::CAI
  include GraphDB::DB

  attr_reader :file_type, :cai_file, :import_id, :db_config, :account_name, :db

  def initialize(file_type, cai_file, import_id, db_config, account_name)
    @file_type = file_type
    @cai_file = cai_file
    @import_id = import_id
    @db_config = db_config
    @account_name = account_name
    @db = db_connection
  end

  def load_cai_file
    return unless validate_cai_file(cai_file)
    parse_cai(cai_file)
  end

  def enrich_data
    query = """
      MATCH (np:GCP_CONTAINER_NODEPOOL)-[hsa:HAS_SERVICEACCOUNT]->(gi:GCP_IDENTITY)
      WHERE gi.name = 'serviceAccount:default'
      DETACH DELETE hsa RETURN np.name as name
    """
    container_nodepools = db.query(query).resultset
    if container_nodepools.is_a?(Array) && !container_nodepools.empty? && container_nodepools.first.length > 0
      container_nodepools.each do |container_nodepool|
        if container_nodepool.is_a?(Array) && !container_nodepool.empty? && container_nodepool.first.length > 0
          container_nodepool = container_nodepool.first
          # Get project name from instance_template path
          gcp_compute_project = container_nodepool.split('/').slice(0 .. 2).join('/').gsub(/^container/, 'compute')
          query = """
            MATCH (np:GCP_CONTAINER_NODEPOOL { name: \"#{container_nodepool}\" }) 
            MATCH (gcp:GCP_COMPUTE_PROJECT { name: \"#{gcp_compute_project}\" })
            MATCH (gi:GCP_IDENTITY) WHERE gi.member_type = \"serviceAccount\" and gi.member_name = gcp.resource_data_defaultServiceAccount
            MERGE (np)-[:HAS_SERVICEACCOUNT]->(gi)
          """
          print '.'
          db.query(query)
        end
      end
    end

    query = """
      MATCH (it:GCP_COMPUTE_INSTANCETEMPLATE)-[hsa:HAS_SERVICEACCOUNT]->(gi:GCP_IDENTITY)
      WHERE gi.name = 'serviceAccount:default'
      DETACH DELETE hsa RETURN it.name as name
    """
    instance_templates = db.query(query).resultset
    if instance_templates.is_a?(Array) && !instance_templates.empty? && instance_templates.first.length > 0
      instance_templates.each do |instance_template|
        if instance_template.is_a?(Array) && !instance_template.empty? && instance_template.first.length > 0
          instance_template = instance_template.first
          # Get project name from instance_template path
          gcp_compute_project = instance_template.split('/').slice(0 .. 2).join('/')
          query = """
            MATCH (i:GCP_COMPUTE_INSTANCETEMPLATE { name: \"#{instance_template}\" }) 
            MATCH (gcp:GCP_COMPUTE_PROJECT { name: \"#{gcp_compute_project}\" })
            MATCH (gi:GCP_IDENTITY) WHERE gi.member_type = \"serviceAccount\" and gi.member_name = gcp.resource_data_defaultServiceAccount
            MERGE (i)-[:HAS_SERVICEACCOUNT]->(gi)
          """
          print '.'
          db.query(query)
        end
      end
    end
    puts ""
  end

  def install_indexes
    query = """
      MATCH (a) RETURN DISTINCT labels(a) as label
    """
    labels = db.query(query).resultset
    if labels.is_a?(Array) && !labels.empty? && labels.first.length > 0
      labels.each do |label|
        if label.is_a?(Array) && !label.empty? && label.first.length > 0
          label = label.first
          query = """
            CREATE INDEX ON :#{label}(name);
            CREATE INDEX ON :#{label}(last_updated);
            CREATE INDEX ON :#{label}(loader_type);
          """
          print '.'
          db.query(query)
        end
      end
    end
    puts ""
  end

  def cleanup_data
    print "."
    query = """
      MATCH ()-[r]-() where r.last_updated <> #{import_id} delete r
    """
    db.query(query)

    print "."
    query = """
      MATCH (n) where n.last_updated <> #{import_id} detach delete n
    """
    db.query(query)
    puts ""
  end

  private

  def validate_cai_file(file)
    begin
      raise Exception.new "CAI file #{file} not found" unless File.file?(file)
      validate_cai(file)
      return true
    rescue Exception => e
      puts "Error importing #{file}, #{e.message}"
    end
    return false
  end

  def parse_cai(cai_file)
    IO.foreach(cai_file) do |line|
      load_asset(parse_json_line(line))
    end
    puts ""
  end

  def load_asset(asset)
    return if asset['asset_type'] == "compute.googleapis.com/InstanceTemplate" && asset['name'] =~ /\/zones\//
    # GCP CAI have ancestors
    unless asset['ancestors'].nil?
      # GCP CAI K8s resources are incomplete
      return if asset['asset_type'].start_with?('k8s.io')
      unless asset['iam_policy'].nil?
        # GCP CAI IAM
        GCPIAMLoader.new(asset, db, import_id)
      else
        # GCP CAI Resource
        GCPLoader.new(asset, db, import_id)
      end
    else
      # Custom K8s/GKE export
      if asset['asset_type'].start_with?('k8s.io')
        K8sLoader.new(asset, db, import_id)
      end
      if asset['asset_type'] == "iam.googleapis.com/ExportedIAMRole"
        GCPIAMRolesLoader.new(asset, db, import_id)
      end
    end
  end

  def db_connection
    self.db_conn(account_name, db_config)
  end
end

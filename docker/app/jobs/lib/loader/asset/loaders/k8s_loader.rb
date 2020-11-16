class K8sLoader < AssetLoader

  attr_reader :asset, :import_id, :db

  def initialize(asset, db, import_id)
    @asset = asset
    @db = db
    @import_id = import_id
    @asset_name = sanitize_value(@asset['name'])
    @asset_type = sanitize_value(@asset['asset_type'])
    @asset_label = k8s_resource_label(@asset_type)

    load
  end

  def load
    puts "k8sloader #{@asset_name} #{@asset_label}"
    # Add resource
    k8s_resource_query(@asset, @asset_type, @asset_label, @asset_name)
    # Add cluster relationship
    k8s_cluster_relationship(@asset_label, @asset_name)
    # Add namespace relationship if needed
    k8s_namespace_relationship(@asset, @asset_label, @asset_name)
  end

  private

  def k8s_resource_query(asset, asset_type, asset_label, asset_name)
    previous_properties_as_null = fetch_current_properties_as_null(asset_label, asset_name)
    properties = prepare_properties(asset)
    q = """MERGE (a:#{asset_label} { name: \"#{asset_name}\" })
    ON CREATE set a.name = \"#{asset_name}\",
                  a.asset_type = \"#{asset_type}\",
                  a.last_updated = #{import_id},
                  a.type = 'k8s',
                  a.loader_type = 'k8s',
                  #{properties}
    ON MATCH  set #{previous_properties_as_null}
                  a.name = \"#{asset_name}\",
                  a.asset_type = \"#{asset_type}\",
                  a.last_updated = #{import_id},
                  a.type = 'k8s',
                  a.loader_type = 'k8s',
                  #{properties}
    """
    graphquery(q)
  end

  def k8s_cluster_relationship(asset_label, asset_name)
   cluster = k8s_cluster_name(asset_name)
   q = """
     MATCH (a:#{asset_label} { name: \"#{asset_name}\" })
     MERGE (c:K8S_CLUSTER { name: \"#{cluster}\" })
     ON CREATE SET c.asset_type = \"k8s.io/Cluster\", c.last_updated = #{@import_id}, c.loader_type = \"k8s\"
     ON MATCH SET c.asset_type = \"k8s.io/Cluster\", c.last_updated = #{@import_id}, c.loader_type = \"k8s\"
     MERGE (c)<-[:IN_CLUSTER]-(a)
   """
   graphquery(q)

   # TODO: Relate to GKE or EKS cluster resource if available
  end

  def k8s_cluster_name(asset_name)
    # "container.googleapis.com/projects/demo1-bad/locations/us-central1-c/clusters/cluster-1/apis/apiregistration.k8s.io/v1/apiservices/v1" becomes:
    # "container.googleapis.com/projects/demo1-bad/locations/us-central1-c/clusters/cluster-1"
    asset_name.match(/(.*\/clusters\/[a-zA-Z0-9\-_]*)\//)[1]
  end

  def k8s_namespace_relationship(asset, asset_label, asset_name)
    namespace = asset.dig('resource','data','metadata','namespace')
    unless namespace.nil?
      cluster = k8s_cluster_name(asset_name)
      q = """
        MATCH (a:#{asset_label} { name: \"#{asset_name}\" })
        MERGE (n:K8S_NAMESPACE { name: \"#{cluster}/api/v1/namespaces/#{namespace}\" })
        ON CREATE SET n.asset_type = \"k8s.io/Namespace\", n.last_updated = #{@import_id}, n.loader_type = \"k8s\"
        ON MATCH SET n.asset_type = \"k8s.io/Namespace\", n.last_updated = #{@import_id}, n.loader_type = \"k8s\"
        MERGE (n)-[:HAS_RESOURCE]->(a)
      """
      graphquery(q)
    end
  end

  def k8s_resource_label(asset_type)
    return "K8S_#{asset_type.gsub(/^k8s.io\//, '').upcase}"
  end
end

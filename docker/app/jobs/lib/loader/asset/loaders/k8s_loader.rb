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
    #puts "k8sloader #{@asset_name} #{@asset_label}"
    # unused
    return if @asset_label == "K8S_TOPNODES"
    return if @asset_label == "K8S_TOPPODS"

    # Add the current resource
    k8s_resource_upsert(@asset, @asset_type, @asset_label, @asset_name)

    # Add supporting relationships to that resource
    k8s_cluster_relationship(@asset_label, @asset_name)
    cloud_cluster_relationship(@asset_name) if @asset_label == "K8S_VERSION"
    k8s_namespace_relationship(@asset, @asset_label, @asset_name)

    # Conditionally run extra relationship creation
    k8s_pod_node_relationship(@asset, @asset_type, @asset_label, @asset_name) if @asset_label == "K8S_POD"
    cloud_node_relationship(@asset, @asset_type, @asset_label, @asset_name) if @asset_label == "K8S_NODE"
  end

  private

  # Upserts a k8s.io/<Resource>
  def k8s_resource_upsert(asset, asset_type, asset_label, asset_name)
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

  # Maps the k8s.io/<Resource> to a generic K8S_CLUSTER
  def k8s_cluster_relationship(asset_label, asset_name)
    cluster = k8s_cluster_name(asset_name)
    supporting_relationship(asset_label, asset_name, "K8S_CLUSTER", cluster, "k8s.io/Cluster", "k8s", "HAS_K8SRESOURCE")
  end

  # Maps tke k8s.io/<Resource> to a K8S_NAMESPACE if it's namespaced
  def k8s_namespace_relationship(asset, asset_label, asset_name)
    namespace = asset.dig('resource','data','metadata','namespace')
    unless namespace.nil?
      cluster = k8s_cluster_name(asset_name)
      supporting_relationship(asset_label, asset_name, "K8S_NAMESPACE", "#{cluster}/api/v1/namespaces/#{namespace}", "k8s.io/Namespace", "k8s", "HAS_RESOURCE")
    end
  end

  # Maps the k8s.io/Pod to a K8S_NODE
  def k8s_pod_node_relationship(asset, asset_type, asset_label, asset_name)
    if asset_name.match(/^container.googleapis.com/)
      cluster = k8s_cluster_name(asset_name)
      spec_node_name = asset.dig('resource', 'data', 'spec', 'nodeName')
      node_name = "#{cluster}/api/v1/nodes/#{spec_node_name}"
      unless cluster.nil? && spec_node_name.nil? && node_name.nil?
        supporting_relationship("K8S_POD", asset_name, "K8S_NODE", node_name, "k8s.io/Node", "k8s", "ON_NODE")
      end
    end
  end

  # Maps the K8S_NODE to the corresponding GCP or AWS Instance Resource
  def cloud_node_relationship(asset, asset_type, asset_label, asset_name)
    if asset_name.match(/^container.googleapis.com/)
      project_id = asset_name.match(/^container.googleapis.com\/projects\/([a-zA-Z0-9\-_]*)\//)[1]
      zone = asset.dig('resource', 'data', 'metadata', 'labels', 'failure-domain.beta.kubernetes.io/zone')
      instance_name = asset.dig('resource', 'data', 'metadata', 'name')
      unless instance_name.nil? && project_id.nil? && zone.nil?
        gce_instance_name = "compute.googleapis.com/projects/#{project_id}/zones/#{zone}/instances/#{instance_name}"
        supporting_relationship("K8S_NODE", asset_name, "GCP_COMPUTE_INSTANCE", gce_instance_name, "compute.googleapis.com/Instance", "gcp", "HAS_K8SNODE")
      end
    end
  end

  # Mpas the K8S_CLUSTER to the corresponding GKE or EKS Cluster Resource
  def cloud_cluster_relationship(asset_name)
    # TODO: EKS Relation
    cluster = k8s_cluster_name(asset_name)
    if asset_name.match(/^container.googleapis.com/)
      # GKE
      supporting_relationship("K8S_CLUSTER", cluster, "GCP_CONTAINER_CLUSTER", cluster, "container.googleapis.com/Cluster", "k8s", "HAS_K8SCLUSTER")
    end
  end

  # Generic helper to upsert and attach a relationship for a resource
  def supporting_relationship(match_label, match_name, merge_label, merge_name, asset_type, loader_type, relationship)
    q = """
      MATCH (a:#{match_label} { name: \"#{match_name}\" })
      MERGE (n:#{merge_label} { name: \"#{merge_name}\" })
      ON CREATE SET n.asset_type = \"#{asset_type}\",
                    n.last_updated = #{@import_id},
                    n.loader_type = \"#{loader_type}\"
      ON MATCH SET  n.asset_type = \"#{asset_type}\",
                    n.last_updated = #{@import_id},
                    n.loader_type = \"#{loader_type}\"
      MERGE (n)-[:#{relationship}]->(a)
    """
    graphquery(q)
  end

  # Helper to get a GKE cluster name from a K8s Export asset_name
  def k8s_cluster_name(asset_name)
    # "container.googleapis.com/projects/demo1-bad/locations/us-central1-c/clusters/cluster-1/apis/apiregistration.k8s.io/v1/apiservices/v1" becomes:
    # "container.googleapis.com/projects/demo1-bad/locations/us-central1-c/clusters/cluster-1"
    if asset_name.match(/^container.googleapis.com/)
      asset_name.match(/(.*\/clusters\/[a-zA-Z0-9\-_]*)/)[1]
    else
      # up to the first "/"
      asset_name.match(/([a-zA-Z0-9\-_]*)\//)[1]
    end
  end

  # Converts k8s.io/Thing to K8S_THING
  def k8s_resource_label(asset_type)
    return "K8S_#{asset_type.gsub(/^k8s.io\//, '').upcase}"
  end
end

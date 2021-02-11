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

    # These are typically dupes
    return if @asset_name =~ /apis\/extensions\/v1beta/
    return if @asset_name =~ /apis\/extensions\/v1alpha/

    if Object.const_defined?(@asset_label)
      Object.const_get(@asset_label).new(@asset, @db, @import_id)
    else
      k8s_resource_upsert(@asset, @asset_type, @asset_label, @asset_name)
    end

    # Add common supporting relationships to the resource
    k8s_cluster_relationship(@asset_label, @asset_name)
    k8s_namespace_relationship(@asset, @asset_label, @asset_name)
    k8s_ownerreference_relationship(@asset, @asset_label, @asset_name)
  end

  private

  # Upserts a k8s.io/<Resource>
  def k8s_resource_upsert(asset, asset_type, asset_label, asset_name)
    if asset.dig('resource','data','metadata','ownerReferences')
      asset.dig('resource', 'data', 'metadata').delete('ownerReferences')       
    end
    
    # Remove container templates
    if asset.dig('resource','data','spec','template', 'spec', 'containers')
      asset.dig('resource','data','spec','template', 'spec').delete('containers')
    end

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

  # Maps tke k8s.io/<Resource> to an ownerreference resource
  def k8s_ownerreference_relationship(asset, asset_label, asset_name)
    ownerref = asset.dig('resource','data','metadata','ownerReferences')
    unless ownerref.nil?
      ownerref.each do |ref|
        namespace = asset.dig('resource', 'data', 'metadata', 'namespace')
        cluster = k8s_cluster_name(asset_name)
        owner_api_version = ref.dig('apiVersion')
        owner_type = ref.dig('kind')
        owner_name = ref.dig('name')
        # container.googleapis.com/projects/demo1-bad/locations/us-central1/clusters/prod-cluster1/apis/apps/v1/namespaces/kube-system/daemonsets/fluentd-gke
        owner_full_name = "#{cluster}/apis/#{owner_api_version}/namespaces/#{namespace}/#{owner_type.downcase.pluralize}/#{owner_name}"
        owner_label = "K8S_#{owner_type.upcase}"
        unless namespace.nil? && owner_api_version.nil? && owner_type.nil? && owner_name.nil? && owner_label.nil?
          supporting_relationship(asset_label, asset_name, owner_label, owner_full_name, "k8s.io/#{owner_type}", "k8s", "OWNS_K8SRESOURCE")
        end
      end
    end
  end

  # Generic helper to upsert and attach a relationship for a resource
  def supporting_relationship(match_label, match_name, merge_label, merge_name, asset_type, loader_type, relationship, direction = "right")
    if direction == "left"
      relationship_string = " MERGE (n)<-[:#{relationship}]-(a)"
    else
      # right/default
      relationship_string = " MERGE (n)-[:#{relationship}]->(a)"
    end
    q = """
      MATCH (a:#{match_label} { name: \"#{match_name}\" })
      MERGE (n:#{merge_label} { name: \"#{merge_name}\" })
      ON CREATE SET n.asset_type = \"#{asset_type}\",
                    n.last_updated = #{@import_id},
                    n.loader_type = \"#{loader_type}\"
      ON MATCH SET  n.asset_type = \"#{asset_type}\",
                    n.last_updated = #{@import_id},
                    n.loader_type = \"#{loader_type}\"
      #{relationship_string}
    """
    graphquery(q)
  end

  def supporting_relationship_with_attrs(match_label, match_name, merge_label, merge_name, asset_type, merge_properties , loader_type, relationship, relationship_attrs, direction = "right")
    #binding.pry
    attrs_string = prepare_relationship_properties(relationship_attrs)
    attrs_string += ", " unless attrs_string.empty?
    attrs_string += " last_updated: #{@import_id}, loader_type: \"#{loader_type}\""

    if direction == "left"
      relationship_string = " MERGE (a)<-[:#{relationship} { #{attrs_string} }]-(n)"
    else
      # right/default
      relationship_string = " MERGE (a)-[:#{relationship} { #{attrs_string} }]->(n)"
    end
    previous_properties_as_null = fetch_current_properties_as_null(merge_label, merge_name)
    properties = prepare_properties(merge_properties)
    properties = ", #{properties}" unless properties.empty?
    q = """
      MATCH (n:#{match_label} { name: \"#{match_name}\" })
      MERGE (a:#{merge_label} { name: \"#{merge_name}\" })
      ON CREATE SET a.asset_type = \"#{asset_type}\",
                    a.last_updated = #{@import_id},
                    a.loader_type = \"#{loader_type}\"
                    #{properties}
      ON MATCH SET  #{previous_properties_as_null}
                    a.asset_type = \"#{asset_type}\",
                    a.last_updated = #{@import_id},
                    a.loader_type = \"#{loader_type}\"
                    #{properties}
      #{relationship_string}
    """
    #binding.pry
    graphquery(q)
  end

  # Helper to get a GKE cluster name from a K8s Export asset_name
  def k8s_cluster_name(asset_name)
    # "container.googleapis.com/projects/demo1-bad/locations/us-central1-c/clusters/cluster-1/apis/apiregistration.k8s.io/v1/apiservices/v1" becomes:
    # "container.googleapis.com/projects/demo1-bad/locations/us-central1-c/clusters/cluster-1"
    if asset_name.match(/^container.googleapis.com/)
      asset_name.match(/(.*\/clusters\/[a-zA-Z0-9\-_]*)/)[1]
    elsif asset_name.match(/([a-zA-Z0-9\-_]*)\//)
      # up to the first "/"
      asset_name.match(/([a-zA-Z0-9\-_]*)\//)[1]
    else
      asset_name
    end
  end

  # Converts k8s.io/Thing to K8S_THING
  def k8s_resource_label(asset_type)
    return "K8S_#{asset_type.gsub(/^k8s.io\//, '').upcase}"
  end
end

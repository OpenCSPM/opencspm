class K8S_POD < K8sLoader

  def initialize(asset, db, import_id)
    super
  end

  def load

    pod_tolerations = []
    if asset.dig('resource','data','spec','tolerations')
      pod_tolerations = asset.dig('resource', 'data', 'spec').delete('tolerations')
    end

    pod_conditions = []
    if asset.dig('resource','data','status','conditions')
      pod_conditions = asset.dig('resource', 'data', 'status').delete('conditions')
    end

    containers = []
    if asset.dig('resource','data','spec','containers')
      containers = asset.dig('resource', 'data', 'spec').delete('containers')
    end

    pod_volumes = []
    if asset.dig('resource','data','spec','volumes')
      pod_volumes = asset.dig('resource', 'data', 'spec').delete('volumes')
    end

    container_statuses = []
    if asset.dig('resource','data','status','containerStatuses')
      container_statuses = asset.dig('resource', 'data', 'status').delete('containerStatuses')
    end

    #binding.pry
    k8s_resource_upsert(@asset, @asset_type, @asset_label, @asset_name)

    # Maps the k8s.io/Pod to a K8S_NODE
    if @asset_name.match(/^container.googleapis.com/)
      cluster = k8s_cluster_name(@asset_name)
      spec_node_name = @asset.dig('resource', 'data', 'spec', 'nodeName')
      node_name = "#{cluster}/api/v1/nodes/#{spec_node_name}"
      unless cluster.nil? && spec_node_name.nil? && node_name.nil?
        supporting_relationship("K8S_POD", @asset_name, "K8S_NODE", node_name, "k8s.io/Node", "k8s", "ON_NODE")
      end
    end

    unless pod_tolerations.nil?
      pod_tolerations.each do |tol|
        toleration_name = tol['key'] || 'Unnamed'
        tol.delete('key')
        supporting_relationship_with_attrs("K8S_POD", @asset_name, "K8S_PODTOLERATION", toleration_name, "k8s.io/PodToleration", {}, "k8s", "HAS_K8SPODTOLERATION", tol, "right")
      end
    end

    unless pod_conditions.nil?
      pod_conditions.each do |pc|
        pc_name = pc['type'] || 'Unnamed'
        pc.delete('type')
        supporting_relationship_with_attrs("K8S_POD", @asset_name, "K8S_PODCONDITION", pc_name, "k8s.io/PodCondition", {}, "k8s", "HAS_K8SPODCONDITION", pc, "right")
      end
    end
  end
end

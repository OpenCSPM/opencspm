class K8S_NODE < K8sLoader

  def initialize(asset, db, import_id)
    super
  end

  def load

    node_status_conditions = @asset.dig('resource', 'data', 'status', 'conditions')
    node_images = @asset.dig('resource', 'data', 'status', 'images')
    unless node_status_conditions.nil?
      @asset.dig('resource', 'data', 'status').delete('conditions')
    end
    unless node_images.nil?
      @asset.dig('resource', 'data', 'status').delete('images')
    end

    k8s_resource_upsert(@asset, @asset_type, @asset_label, @asset_name)

    # Maps the K8S_NODE to the corresponding GCP or AWS Instance Resource
    if @asset_name.match(/^container.googleapis.com/)
      project_id = @asset_name.match(/^container.googleapis.com\/projects\/([a-zA-Z0-9\-_]*)\//)[1]
      zone = @asset.dig('resource', 'data', 'metadata', 'labels', 'failure-domain.beta.kubernetes.io/zone')
      instance_name = @asset.dig('resource', 'data', 'metadata', 'name')
      unless instance_name.nil? && project_id.nil? && zone.nil?
        gce_instance_name = "compute.googleapis.com/projects/#{project_id}/zones/#{zone}/instances/#{instance_name}"
        supporting_relationship("K8S_NODE", @asset_name, "GCP_COMPUTE_INSTANCE", gce_instance_name, "compute.googleapis.com/Instance", "gcp", "HAS_K8SNODE", "right")
      end
    end

    unless node_status_conditions.nil?
      node_status_conditions.each do |condition|
        condition_type = condition['type']
        condition.delete('type')
        supporting_relationship_with_attrs("K8S_NODE", @asset_name, "K8S_NODECONDITION", condition_type, "k8s.io/NodeCondition", {}, "k8s", "HAS_K8SNODECONDITION", condition, "left")
      end
    end
  end
end

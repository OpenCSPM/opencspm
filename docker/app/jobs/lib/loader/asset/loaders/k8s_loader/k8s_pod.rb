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

    k8s_resource_upsert(@asset, @asset_type, @asset_label, @asset_name)

    # Create K8S_CONTAINERVOLUME
    unless pod_volumes.nil?
      pod_volumes.each do |vol|
        volume_name = vol['name'] || 'unnamed'
        volume_name = "#{@asset_name}/podvolume/#{volume_name}"
        vol.delete('name')
        # TODO: Parse ConfigMap and Secret relationships
        supporting_relationship_with_attrs("K8S_POD", @asset_name, "K8S_PODVOLUME", volume_name, "k8s.io/PodVolume", vol, "k8s", "HAS_K8SPODVOLUME", {}, "left")
      end
    end

    unless containers.nil?
      containers.each do |container|
        if container.dig('command')
          container['command'] = container.dig('command').join " "
        end
        container_image = "unknown"
        if container.dig('image')
          container_image = container.delete('image')
        end
        # TODO Init Containers
        # TODO:Join liveness/readiness command
        # TODO Parse ENV Vars
        # TODO ServiceAccount Name
        # Create K8S_CONTAINER 
        container_name = "#{@asset_name}/container/#{container['name']}"
        supporting_relationship_with_attrs("K8S_POD", @asset_name, "K8S_CONTAINER", container_name, "k8s.io/PodContainer", container, "k8s", "HAS_K8SCONTAINER", {}, "left")

        # Create K8S_CONTAINERVOLUMEMOUNT
        container_volume_mounts = []
        if container.dig('volumeMounts')
          container_volume_mounts = container.delete('volumeMounts')
          unless container_volume_mounts.nil?
            container_volume_mounts.each do |vol|
              volume_name = vol['name'] || 'unnamed'
              vol.delete('name')

              pod_volume_name = "#{@asset_name}/podvolume/#{volume_name}"
              volume_mount_name = "#{container_name}/volumemount/#{volume_name}"
              supporting_relationship_with_attrs("K8S_PODVOLUME", pod_volume_name, "K8S_CONTAINER", container_name, "k8s.io/Container", container, "k8s", "HAS_K8SCONTAINERVOLUMEMOUNT", vol, "left")
            end
          end
        end
 
        # Create OCI_CONTAINERIMAGE 
        unless container_image.nil?
          supporting_relationship_with_attrs("K8S_CONTAINER", container_name, "OCI_CONTAINERIMAGE", container_image, "oci/ContainerImage", {}, "k8s", "HAS_OCICONTAINERIMAGE", {}, "left")
        end
      end
    end

    # Maps the k8s.io/Pod to a K8S_NODE
    if @asset_name.match(/^container.googleapis.com/)
      cluster = k8s_cluster_name(@asset_name)
      spec_node_name = @asset.dig('resource', 'data', 'spec', 'nodeName')
      node_name = "#{cluster}/api/v1/nodes/#{spec_node_name}"
      unless cluster.nil? && spec_node_name.nil? && node_name.nil?
        supporting_relationship("K8S_POD", @asset_name, "K8S_NODE", node_name, "k8s.io/Node", "k8s", "ON_NODE", "left")
      end
    end

    # Pod tolerations
    unless pod_tolerations.nil?
      pod_tolerations.each do |tol|
        toleration_name = tol['key'] || 'Unnamed'
        tol.delete('key')
        supporting_relationship_with_attrs("K8S_POD", @asset_name, "K8S_PODTOLERATION", toleration_name, "k8s.io/PodToleration", {}, "k8s", "HAS_K8SPODTOLERATION", tol, "left")
      end
    end

    # Pod conditions
    unless pod_conditions.nil?
      pod_conditions.each do |pc|
        pc_name = pc['type'] || 'Unnamed'
        pc.delete('type')
        supporting_relationship_with_attrs("K8S_POD", @asset_name, "K8S_PODCONDITION", pc_name, "k8s.io/PodCondition", {}, "k8s", "HAS_K8SPODCONDITION", pc, "left")
      end
    end
  end
end

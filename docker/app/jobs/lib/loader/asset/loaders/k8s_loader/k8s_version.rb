class K8S_VERSION < K8sLoader

  def initialize(asset, db, import_id)
    super
  end

  def load
    k8s_resource_upsert(@asset, @asset_type, @asset_label, @asset_name)

    # Maps the K8S_CLUSTER to the corresponding GKE or EKS Cluster Resource
    # TODO: EKS Relation
    cluster = k8s_cluster_name(@asset_name)
    if @asset_name.match(/^container.googleapis.com/)
      # GKE
      supporting_relationship("K8S_CLUSTER", cluster, "GCP_CONTAINER_CLUSTER", cluster, "container.googleapis.com/Cluster", "k8s", "HAS_K8SCLUSTER", "right")
    end
  end
end

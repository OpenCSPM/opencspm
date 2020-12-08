class K8S_PERSISTENTVOLUMECLAIM < K8sLoader

  def initialize(asset, db, import_id)
    super
  end

  def load

    k8s_resource_upsert(@asset, @asset_type, @asset_label, @asset_name)

    cluster = k8s_cluster_name(@asset_name)
    spec_sc_name = @asset.dig('resource', 'data', 'spec', 'storageClassName') || 'standard'
    sc_name = "#{cluster}/apis/storage.k8s.io/v1/storageclasses/#{spec_sc_name}"
    unless spec_sc_name.nil? && sc_name.nil?
      supporting_relationship(@asset_label, @asset_name, "K8S_STORAGECLASS", sc_name, "k8s.io/StorageClass", "k8s", "HAS_K8SSTORAGECLASS", "left")
    end
  end
end

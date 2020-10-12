class GCP_CONTAINER_NODEPOOL < GCPLoader

  def initialize(asset, db, import_id)
    super
  end

  def load
    # skipped because it's obtained from GCP_CONTAINER_CLUSTER
  end
end

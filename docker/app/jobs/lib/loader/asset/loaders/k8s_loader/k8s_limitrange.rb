class K8S_LIMITRANGE < K8sLoader

  def initialize(asset, db, import_id)
    super
  end

  def load

    limitrange_items = []
    if asset.dig('resource','data','spec','limits')
      limitrange_items = asset.dig('resource', 'data', 'spec').delete('limits')
    end

    k8s_resource_upsert(@asset, @asset_type, @asset_label, @asset_name)

    unless limitrange_items.nil?
      limitrange_items.each do |lr|
        lr_name = lr['type'] || 'Unnamed'
        lr_name = "#{@asset_name}/#{lr_name}"
        lr.delete('type')
        supporting_relationship_with_attrs("K8S_LIMITRANGE", @asset_name, "K8S_LIMITRANGEITEM", lr_name, "k8s.io/LimitRangeItem", lr, "k8s", "HAS_K8SLIMITRANGEITEM", {}, "left")
      end
    end
  end
end

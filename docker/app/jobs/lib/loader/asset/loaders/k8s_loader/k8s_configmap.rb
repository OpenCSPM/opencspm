class K8S_CONFIGMAP < K8sLoader

  def initialize(asset, db, import_id)
    super
  end

  def load

    # Chop down configmap values
    if asset.dig('resource','data','data')
      asset.dig('resource','data','data').keys.each do |key|
        asset['resource']['data']['data'][key] = asset['resource']['data']['data'][key][0..100]
      end
    end
    k8s_resource_upsert(asset, @asset_type, @asset_label, @asset_name)

  end
end

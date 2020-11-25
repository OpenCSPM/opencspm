class K8S_SERVICE < K8sLoader

  def initialize(asset, db, import_id)
    super
  end

  def load

    service_ports = []
    if asset.dig('resource','data','spec','ports')
      service_ports = asset.dig('resource', 'data', 'spec').delete('ports')
    end

    k8s_resource_upsert(@asset, @asset_type, @asset_label, @asset_name)

    unless service_ports.nil?
      service_ports.each do |sp|
        sp_name = sp['name'] || "#{sp['protocol']}-#{sp['port']}"
        sp.delete('name')
        supporting_relationship_with_attrs("K8S_SERVICE", @asset_name, "K8S_SERVICEPORT", sp_name, "k8s.io/ServicePort", sp, "k8s", "HAS_K8SSERVICEPORT", {}, "left")
      end
    end
  end
end

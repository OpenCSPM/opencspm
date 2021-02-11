class K8S_ENDPOINTS < K8sLoader

  def initialize(asset, db, import_id)
    super
  end

  def load

    subsets = []
    if asset.dig('resource','data','subsets')
      subsets = asset.dig('resource', 'data').delete('subsets')
    end
 
    k8s_resource_upsert(@asset, @asset_type, @asset_label, @asset_name)

    unless subsets.nil?
      subsets.each do |subset|
        addresses = subset.dig('addresses') || []
        ports = subset.dig('ports') || []

        # "upstream" cluster service mapping
        if matches = @asset_name.match(%r{(?<base>.*\/)endpoints\/(?<svcname>.*)})
          full_svc_name = "#{matches[:base]}services/#{matches[:svcname]}"
          supporting_relationship_with_attrs("K8S_ENDPOINTS", @asset_name, "K8S_SERVICE", full_svc_name, "k8s.io/Service", {}, "k8s", "HAS_K8SENDPOINT", {}, "right")
        end

        if addresses.length > 0 && ports.length > 0
          addresses.each do |addr|
            ip = addr.dig('ip')
            targettype = addr.dig('targetRef', 'kind')
            pod_name = addr.dig('targetRef', 'name')

            if targettype == 'Pod'

              # targetref -> K8S_POD
              ports.each do |port|
                if matches = @asset_name.match(%r{(?<base>.*\/)endpoints\/.*})
                  full_pod_name = "#{matches[:base]}pods/#{pod_name}"
                  supporting_relationship_with_attrs("K8S_ENDPOINTS", @asset_name, "K8S_POD", full_pod_name, "k8s.io/Pod", {}, "k8s", "HAS_K8SENDPOINTPORT", port, "left")
                end
              end
            else
              # Plain IP -> K8S_ENDPOINTIP
              ports.each do |port|
                supporting_relationship_with_attrs("K8S_ENDPOINTS", @asset_name, "K8S_ENDPOINTIP", ip, "k8s.io/ServicePort", {}, "k8s", "HAS_K8SENDPOINTPORT", port, "left")
              end
            end
          end
        end
      end
    end
  end
end

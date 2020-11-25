class K8S_CLUSTERROLE < K8sLoader

  def initialize(asset, db, import_id)
    super
  end

  def load

    rules = []
    if asset.dig('resource','data','rules')
      rules = asset.dig('resource', 'data').delete('rules')
    end

    k8s_resource_upsert(@asset, @asset_type, @asset_label, @asset_name)

    unless rules.nil?
      rules.each do |rule|
        api_groups = rule.dig('apiGroups') || ["core"]
        resources = rule.dig('resources') || ['all']
        resource_names = rule.dig('resourceNames') || ['all']
        non_resource_urls = rule.dig('nonResourceURLs') || []
        verbs = rule.dig('verbs') || ['all']

        api_groups.each do |apigroup|
          apigroup = 'all' if apigroup == '*'
          apigroup = 'core' if apigroup == ''
          resources.each do |resource|
            resource = 'all' if resource == '*'
            res_attrs = { "apigroup" => apigroup, "resource" => resource }
            if non_resource_urls == []
              resource_names.each do |resource_name|
                resource_name = 'all' if resource_name == '*'
                verbs.each do |verb|
                  verb = 'all' if verb == '*'
                  rel_attrs = { "resource_name" => resource_name, "verb" => verb }
                  supporting_relationship_with_attrs("K8S_CLUSTERROLE", @asset_name, "K8S_RBAC_RESOURCE", "#{apigroup}/#{resource}", "k8s.io/RbacResource", res_attrs, "k8s", "HAS_RBAC_RULE", rel_attrs, "left")
                end
              end
            else
              non_resource_urls.each do |non_resource_url|
                non_resource_url = ['all'] if non_resource_url == ['*']
                verbs.each do |verb|
                  verb = 'all' if verb == '*'
                  rel_attrs = { "non_resource_url" => non_resource_url, "verb" => verb }
                  supporting_relationship_with_attrs("K8S_CLUSTERROLE", @asset_name, "K8S_RBAC_RESOURCE", "#{apigroup}/#{resource}", "k8s.io/RbacResource", res_attrs, "k8s", "HAS_RBAC_RULE", rel_attrs, "left")
                end
              end
            end
          end
        end 
      end
    end
  end
end

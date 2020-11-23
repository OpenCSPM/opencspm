class K8S_SERVICEACCOUNT < K8sLoader

  def initialize(asset, db, import_id)
    super
  end

  def load

    secret_names = []
    if asset.dig('resource','data','secrets')
      secret_names = asset.dig('resource', 'data').delete('secrets')
    end
    k8s_resource_upsert(@asset, @asset_type, @asset_label, @asset_name)

    unless secret_names.nil?
      secret_names.each do |secret|
        secret_name = secret['name'] || "Unnamed"
        secret.delete('name')
        if matches = @asset_name.match(%r{(?<base>.*\/)serviceaccounts\/(?<saname>.*)})
          full_secret_name = "#{matches[:base]}secrets/#{secret_name}"
          supporting_relationship_with_attrs("K8S_SERVICEACCOUNT", @asset_name, "K8S_SECRET", full_secret_name, "k8s.io/Secret", {}, "k8s", "HAS_K8SSECRET", {}, "left")
        end
      end
    end
  end
end

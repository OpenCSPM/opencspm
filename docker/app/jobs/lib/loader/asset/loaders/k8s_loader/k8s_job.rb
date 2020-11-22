class K8S_JOB < K8sLoader

  def initialize(asset, db, import_id)
    super
  end

  def load

    job_conditions = []
    if asset.dig('resource','data','status','conditions')
      job_conditions = asset.dig('resource', 'data', 'status').delete('conditions')
    end

    k8s_resource_upsert(@asset, @asset_type, @asset_label, @asset_name)

    unless job_conditions.nil?
      job_conditions.each do |jc|
        jc_name = jc['type'] || 'Unnamed'
        jc.delete('type')
        supporting_relationship_with_attrs("K8S_JOB", @asset_name, "K8S_JOBCONDITION", jc_name, "k8s.io/JobCondition", {}, "k8s", "HAS_K8SJOBCONDITION", jc, "left")
      end
    end
  end
end

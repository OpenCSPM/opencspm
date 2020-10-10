class GCP_IAM_SERVICEACCOUNT < GCPLoader

  def initialize(asset, db, import_id)
    super
  end

  def load
    # modify to GCP_IDENTITY
    @asset_label = 'GCP_IDENTITY'
    sa_email = asset.dig('resource', 'data', 'email')
    @asset_name = "serviceAccount:#{sa_email}"
    # create/update gcp asset
    previous_properties_as_null = fetch_current_properties_as_null(@asset_label, @asset_name)
    # TODO Deep parsing 
    properties = prepare_properties(asset)
    query = """
      MERGE (a:#{@asset_label} { name: \"#{@asset_name}\" })
      ON CREATE SET a.asset_type = \"#{@asset_type}\", a.last_updated = #{@import_id}, a.member_type = \"serviceAccount\", a.member_name = \"#{sa_email}\", a.loader_type = \"gcp\", #{properties}
      ON MATCH SET #{previous_properties_as_null} a.asset_type = \"#{@asset_type}\", a.last_updated = #{@import_id}, a.member_type = \"serviceAccount\", a.member_name = \"#{sa_email}\", a.loader_type = \"gcp\", #{properties}
    """
    graphquery(query)
  end
end

class GCP_DEFAULT < GCPLoader

  def initialize(asset, db, import_id)
    super
  end

  def load

    return if @asset_label == 'GCP_CONTAINERREGISTRY_IMAGE'
    # Remove ancestors
    asset.delete('ancestors')

    # create/update gcp asset
    previous_properties_as_null = fetch_current_properties_as_null(@asset_label, @asset_name)
    properties = prepare_properties(asset)
    query = """
      MERGE (a:#{@asset_label} { name: \"#{@asset_name}\" })
      ON CREATE SET a.asset_type = \"#{@asset_type}\",
                    a.last_updated = #{@import_id},
                    a.loader_type = \"gcp\",
                    #{properties}
      ON MATCH SET  #{previous_properties_as_null}
                    a.asset_type = \"#{@asset_type}\",
                    a.last_updated = #{@import_id},
                    a.loader_type = \"gcp\",
                    #{properties}
    """
    graphquery(query)
  end
end

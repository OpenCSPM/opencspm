require_relative 'enumerable'

class AssetLoader

  def initialize
  end

  def load
    raise NotImplementedEror
  end

  private

  def sanitize_value(value)
    value = CGI.escape(value) if value.start_with?("{")
    value.gsub(/^\/\//,'') unless value.nil?
  end

  def get_gcp_asset_label(asset_type)
    if asset_type =~ /\.googleapis\.com\//
      label = asset_type.gsub(/\.googleapis\.com\//, '_').split('/').first.upcase
      label = label.gsub(/_ORGANIZATIONS$/, '_ORGANIZATION')
      label = label.gsub(/_FOLDERS$/, '_FOLDER')
      label = label.gsub(/_PROJECTS$/, '_PROJECT')
      return "GCP_#{label}"
    end
  end

  def get_gcp_asset_parent(asset_label, ancestors)
    gcp_base = 'cloudresourcemanager.googleapis.com/'  
    case asset_label
    when 'GCP_CLOUDRESOURCEMANAGER_FOLDER', 'GCP_CLOUDRESOURCEMANAGER_PROJECT'
      return gcp_base + ancestors[1]
    else
      return gcp_base + ancestors.first 
    end
  end

  def graphquery(query, params = {})
    print "."
    db.query(query)
  end

  def fetch_current_properties_as_null(asset_label, asset_name)
    current_properties = graphquery("match(n:#{asset_label} { name: \"#{asset_name}\" }) return (n)").resultset
    return "" if current_properties == []
    current_properties = current_properties.first.first.reduce(Hash.new, :merge).tap {|hs| hs.delete('name') }.tap { |hs| hs.delete('asset_type') }.map { |h| "a.#{h[0]} = NULL" }.join ', '
    return "" if current_properties == ""
    current_properties + ', ' 
  end

  def prepare_properties(asset)
    asset.flatten_with_path.tap {|hs| hs.delete('name') }.tap { |hs| hs.delete('asset_type') }.map { |h| "a.#{h[0]} = \"#{h[1]}\"" }.join ', '
  end
end

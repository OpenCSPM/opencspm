# frozen-string-literal: true

# comment
class GCPLoader < AssetLoader
  attr_reader :asset, :import_id, :db, :asset_name, :asset_type, :asset_label, :asset_parent, :asset_parent_label

  def initialize(asset, db, import_id)
    @asset = asset
    @db = db
    @import_id = import_id
    @asset_name = sanitize_value(asset['name'])
    @asset_type = sanitize_value(asset['asset_type'])
    # get capitalized/canoncialized asset label
    @asset_label = get_gcp_asset_label(asset_type)
    # get the full name of this asset's parent resource
    @asset_parent = get_gcp_asset_parent(asset_label, asset['ancestors'])
    # get capitalized/canoncialized asset label of its parent
    @asset_parent_label = get_gcp_asset_label(asset_parent)

    # Skip GCP CAI K8s resources
    return if asset_type =~ /k8s.io\//

    load
  end

  # See if a custom loader is defined or send to the default
  def load
    if Object.const_defined?(asset_label)
      Object.const_get(asset_label).new(asset, db, import_id)
    else
      GCP_DEFAULT.new(asset, db, import_id)
    end

    add_resource_hierarchy(asset_label, asset_name, asset_parent_label, asset_parent)
  end

  private

  def add_resource_hierarchy(asset_label, asset_name, asset_parent_label, asset_parent)
    # Organization has no parents
    return if asset_label == 'GCP_CLOUDRESOURCEMANAGER_ORGANIZATION'

    rel_query = """
      MATCH (a:#{asset_label} { name: \"#{asset_name}\" })
      MERGE (p:#{asset_parent_label} { name: \"#{asset_parent}\" })
      MERGE (a)-[:IN_HIERARCHY]->(p)
    """
    rel_query += add_resource_relationship(asset_label)

    # add hierarchy relationships
    graphquery(rel_query)

  end

  def add_resource_relationship(asset_label)
    # hierarchy relationships
    case asset_label
      when 'GCP_CLOUDRESOURCEMANAGER_FOLDER'
        " MERGE (p)-[:HAS_FOLDER]->(a)"
      when 'GCP_CLOUDRESOURCEMANAGER_PROJECT'
        " MERGE (p)-[:HAS_PROJECT]->(a)"
      else
        " MERGE (p)-[:HAS_RESOURCE]->(a)"
    end
  end

  def compute_url_to_compute_name(url)
    return "" if url.nil? || url.empty?
    url.gsub(/.*googleapis.com\/compute\/v1/, 'compute.googleapis.com').gsub(/.*container.googleapis.com\/v1/, 'container.googleapis.com')
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
end

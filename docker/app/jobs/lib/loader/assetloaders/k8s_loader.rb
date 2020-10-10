class K8sLoader < AssetLoader

  attr_reader :asset, :import_id, :db

  def initialize(asset, db, import_id)
    @asset = asset
    @db = db
    @import_id = import_id

    load
  end

  def load
    asset_name = sanitize_value(asset['name'])
    puts "k8sloader #{asset_name}"
    puts asset
  end
end

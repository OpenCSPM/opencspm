class AWSLoader::ResourceLoader
  def initialize(asset, db, import_id)
    @asset = asset
    @db = db
    # TODO: use import_id in GraphDbLoader
    @import_id = import_id

    load
  end

  def load
    # re-parse as JSON to get recursive OpenStruct's
    json = JSON.parse(@asset.to_json, object_class: OpenStruct)

    # Instantiate a Loader instance for each service type
    begin
      svc = "::AWSLoader::#{json.service}"
      aws_loader = Object.const_get(svc)
      loader = aws_loader.new(json)

      # DEBUG: skip loader methods that aren't implemented yet
      unless loader.respond_to?(json.asset_type)
        puts "No #{json.service} loader defined for asset type: #{json.asset_type}"
        return
      end

      # call loader method for the asset type
      loader.send(json.asset_type)&.each do |q|
        @db.query(q)
        printf "\x1b[32m.\x1b[0m"
      end
    rescue NameError
      puts "No loader defined for service: #{json.service}"
    end
  end
end

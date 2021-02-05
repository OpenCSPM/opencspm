# frozen_string_literal: true

#
# AWS asset graph db loader
#
class AWSLoader::ResourceLoader
  def initialize(asset, db, import_id)
    @asset = asset
    @db = db
    @import_id = import_id

    load
  end

  def load
    # re-parse as JSON to get recursive OpenStruct's
    json = JSON.parse(@asset.to_json, object_class: OpenStruct)

    # set import_id
    json.import_id = @import_id

    # Instantiate a Loader instance for each service type
    begin
      svc = "::AWSLoader::#{json.service}"
      aws_loader = Object.const_get(svc)
      loader = aws_loader.new(json)

      # DEBUG: skip loader methods that aren't implemented yet
      unless loader.respond_to?(json.asset_type)
        puts "\nWarning: no #{json.service} loader defined for asset type: \x1b[35m#{json.asset_type}\x1b[0m"
        return
      end

      # call loader method for the asset type
      loader.send(json.asset_type)&.each do |q|
        @db.query(q)
        printf "\x1b[32m.\x1b[0m" if ENV['SHOW_DOTS']
      end
    rescue NameError => e
      # Instances of ::GraphDbLoader will raise a NameError exception
      # if the individual methods try to call a non-existent field
      # returned from the AWS API. We don't want to swallow that
      # exception, so re-raise it here.

      # raise e if e.receiver.nil?

      # raise all
      raise e

      # puts "No loader defined for service: #{json.service}"
    end
  end
end

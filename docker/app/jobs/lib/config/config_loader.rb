# frozen-string-literal: true

require 'yaml'
require 'json'
require 'ostruct'

# Loads the list of buckets into an Openstruct
class ConfigLoader
  attr_accessor :loaded_config

  def initialize(config_file_path)
    @loaded_config = JSON.parse(YAML.load_file(config_file_path).to_json, object_class: OpenStruct)
    # TODO: use dry/schema to validate
  end
end

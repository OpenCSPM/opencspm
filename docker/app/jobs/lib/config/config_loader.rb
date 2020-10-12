require 'yaml'
require 'json'
require 'ostruct'

class ConfigLoader
  attr_reader :parsed_config

  def initialize(config_file_path)
    #@parsed_config = YAML.load_file(config_file_path)
    @parsed_config = JSON.parse(YAML::load_file(config_file_path).to_json, object_class: OpenStruct)
    # TODO use dry/schema to validate
  end
end

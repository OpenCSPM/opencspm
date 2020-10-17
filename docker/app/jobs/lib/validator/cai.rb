# frozen-string-literal: true

require 'json'
require 'json_schemer'

# Validation module
module Validator
  # Validates a CAI file format
  module CAI
    def validate_cai(path)
      IO.foreach(path) do |line|
        validate_schema(parse_json_line(line))
      end
    end

    def validate_schema(json)
      cai_schema = Pathname.new('app/jobs/lib/validator/schema/cai.json')
      JSONSchemer.schema(cai_schema).valid?(json)
    end

    def parse_json_line(line)
      JSON.parse(line)
    rescue JSON::ParserError => e
      raise "JSON Parser exception #{e}"
    end
  end
end

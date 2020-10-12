require 'json'
require 'json_schemer'

module Validator
  module CAI
    def validate_cai(path)
      begin
        puts "validation of cai: #{path}"
        raise Exception.new "CAI at #{path} not found" unless File.file?(path)
        IO.foreach(path) do |line|
          validate_schema(parse_json_line(line))
        end
      rescue Exception => e
        puts "Error: Unable to validate the schema of the CAI file at #{path}, #{e.message}"
        return false
      end
        return true
    end

    def validate_schema(json)
      cai_schema = Pathname.new("app/jobs/lib/validator/schema/cai.json")
      JSONSchemer.schema(cai_schema).valid?(json)
    end

    def parse_json_line(line)
      JSON.parse(line)
    rescue JSON::ParserError => e
      raise "JSON Parser exception #{e}"
    end
    
  end
end

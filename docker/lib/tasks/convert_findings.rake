namespace :findings do
  desc 'Convert Darkbit findings.json into controls.yaml'
  task convert: :environment do
    convert_findings
  end

  def convert_findings
    input_file = 'findings.json'
    output_file = 'controls.yaml'

    begin
      json = JSON.load(File.new(input_file))
    rescue StandardError
      puts "Error: missing input file \"#{input_file}\""
      exit 1
    end

    # UUID v5 allows for a constant GUID based on a fixed string (title)
    # e.g. Digest::UUID.uuid_v5(Digest::UUID::OID_NAMESPACE, r['title'])
    data = json['results'].map do |r|
             {
               name: "dbc-#{r['finding']}",
               guid: Digest::UUID.uuid_v5(Digest::UUID::OID_NAMESPACE, r['title']),
               platform: r['platform'].downcase,
               title: r['title'],
               description: r['description'],
               validation: r['validation'] ? "\n#{r['validation']}" : '',
               remediation: r['remediation'] ? "\n#{r['remediation']}" : '',
               impact: (r['severity'] * 10).to_i,
               refs: r['references'],
               tags: ['dbc']
             }
           end.map { |x| x.deep_stringify_keys }

    output = File.open(output_file, 'w') { |file| file.write(data.to_yaml) }
    puts "Wrote #{output.inspect} bytes to #{output_file}."
  end
end

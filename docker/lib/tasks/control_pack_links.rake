# frozen_string_literal: true

namespace :packs do
  desc 'Checks URLs used in Control Packs'
  task check_links: :environment do
    check_links
  end

  def check_links
    puts 'Checking links...'

    controls = []
    urls = []
    broken = []

    # load control packs
    Dir[PACK_BASE_DIR].each do |file|
      next if file.starts_with?('controls/_')

      puts file

      controls.push(
        JSON.parse(
          YAML.safe_load(File.read(file)).to_json, object_class: OpenStruct
        ).controls
      )
    end

    # flatten
    controls = controls.flatten

    controls.each do |control|
      id = control.id

      control.refs.each do |ref|
        next unless ref.url

        next if urls.include?(ref.url)

        urls.push(ref.url)
        link = URI.parse(ref.url)

        next unless link.host && link.path

        begin
          res = URI.open(ref.url)
          puts "#{id} - #{ref.url} - \x1b[32m#{res.status.last}\x1b[0m"
        rescue OpenURI::HTTPError => e
          broken.push("#{id} - #{ref.url}")
          puts "\x1b[35m#{id}\x1b[0m - #{ref.url} (\x1b[35m#{e.message}\x1b[0m)"
        end
      end
    end

    puts "\nChecked #{urls.length} links.\n\n"

    return if broken.empty?

    puts 'Broken links:'

    broken.each do |msg|
      puts "#{msg}\n\n"
    end
  end
end

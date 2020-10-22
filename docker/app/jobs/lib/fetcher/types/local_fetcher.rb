# frozen-string-literal: true

class LocalFetcher
  def initialize(local_dirs, load_dir)
    @local_dirs = local_dirs
    @load_dir = load_dir
  end

  def fetch
    puts @local_dirs
    # Enumerate **/*manifest.txt
    @local_dirs.each do |local_dir|
      Dir["#{local_dir}/*/*manifest.txt"].each do |manifest_file|
        manifest_base_dir = File.dirname(manifest_file)
        cai_files = []
        begin
          File.readlines(manifest_file).each do |cai_file|
            source_file_path = "#{manifest_base_dir}/#{cai_file}".chomp
            dest_file_path = "#{@load_dir}/#{randomize_file_name(cai_file)}"
            puts "Copying from #{source_file_path} to #{dest_file_path}" 
            FileUtils.cp(source_file_path, dest_file_path)
          end
        rescue => e
          puts e.inspect
        end
      end
    end
  end

  private

  def randomize_file_name(file_name)
    # tmp-asdf23fwhj-myfilename.json
    "tmp-#{generate_code(8)}-#{file_name.chomp}"
  end

  def generate_code(number)
    charset = Array('A'..'Z') + Array('a'..'z')
    Array.new(number) { charset.sample }.join
  end
end

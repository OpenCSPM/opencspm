class FileFetcher < DataTypeFetcher

  def fetch_files
    get_files(fetcher_config[:path])
  end

  private

  # Returns an array of files that exist per the contents of the file named "manifest.txt"
  # in the current path
  def get_files(file_path)
    manifest_file = "#{file_path}/manifest.txt" 
    cai_files = []
    begin
      raise Exception.new "Manifest file at #{manifest_file} not found" unless File.file?(manifest_file)
      File.readlines(manifest_file).each do |cai_file|
        full_file_path = "#{file_path}/#{cai_file}"
        cai_files << full_file_path.chomp unless File.file?(full_file_path) 
      end 
    rescue Exception => e
      puts "Error enumerating manifext.txt files to import, #{e.message}"
    end
    cai_files
  end
end

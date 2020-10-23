# require all collectors
Dir[File.join(__dir__, 'loaders', '*.rb')].each { |file| require file }

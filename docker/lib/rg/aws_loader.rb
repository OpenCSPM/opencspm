module AWSLoader
end

# require all collectors
Dir[File.join(__dir__, 'aws_loader', '*.rb')].each { |file| require file }

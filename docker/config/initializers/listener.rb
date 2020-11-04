#
# Reload Controls on changes to `opencspm-controls`
#
CORE_CONTAINER = 'core'.freeze
LISTEN_DIR = File.join(Rails.root, 'controls')
logger = Rails.logger

# Only listen for changes on core container
if File.directory?(LISTEN_DIR) && Socket.gethostname == CORE_CONTAINER
  listener = Listen.to(LISTEN_DIR) do |modified, added, removed|
    logger.debug("modified absolute path: #{modified}")
    logger.debug("added absolute path: #{added}")
    logger.debug("removed absolute path: #{removed}")
    logger.debug('running PackJob...')
    PackJob.new.perform
  end

  # non blocking
  # listener.start

  puts "=> [listener] listening for changes to #{LISTEN_DIR}"
end

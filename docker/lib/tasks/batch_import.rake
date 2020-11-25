$:.unshift('/app/app/jobs/lib')
require 'batch_importer'
require 'pry'

namespace :batch do
  desc 'Loads All Data from Import'
  task import: :environment do
    BatchImporter.new("load_config/config.yaml").import
  end
end

# frozen_string_literal: true

$:.unshift('/app/app/jobs/lib')
require 'batch_importer'
require 'pry'

namespace :batch do
  desc 'Loads All Data from Import'
  task import: :environment do
    BatchImporter.new(LoaderJob::CONFIG_FILE).import
  end
end

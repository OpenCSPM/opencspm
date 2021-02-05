# frozen_string_literal: true

require 'pry'
require 'rspec'
require 'rspec/core'
require 'rspec/core/formatters/base_formatter'
require_relative 'spec/formatters/custom_formatter'
require_relative 'spec/support/db_helper'
require_relative 'spec/support/redisgraph_helper'
require 'json'

#
# Runs all RSpec controls against current graph database
#
class AnalysisJob < ApplicationJob
  queue_as :default
  attr_accessor :output_hash

  TYPE = :analyze

  def perform(args)
    unless args.key?(:guid)
      logger.info 'Analysis job not running without a GUID.'
      return nil
    end

    # shared GUID
    guid = args[:guid]
    logger.info "#{guid} Analysis job started"

    # Track the job
    job = Job.create(status: :running, kind: TYPE, guid: guid)

    begin
      RSpec.world.reset
      RSpec.reset
      RSpec.clear_examples

      custom_formatter = CspmFormatter.new(StringIO.new)
      RSpec::Core::Reporter.new(custom_formatter)

      options = []
      options << Dir['controls/**/controls_spec.rb'].reject { |f| f.starts_with?('controls/_') }
      options << '-fCspmFormatter'
      RSpec::Core::Runner.run(options)

      # results = JSON.parse(File.read(RunnerJob::RESULTS_FILE))

      RSpec.clear_examples
      RSpec.world.reset
      RSpec.reset

      job.complete!
      puts "Analysis job finished - #{guid}"
    rescue StandardError => e
      job.failed!
      puts "#Analysis job failed - #{e.class} #{e.message} (#{e.backtrace[0]})"

      # re-raise for RunnerJob
      raise e
    end
  end
end

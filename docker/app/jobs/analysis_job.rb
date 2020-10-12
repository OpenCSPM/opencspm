require 'pry'
require 'rspec'
require 'rspec/core'
require 'rspec/core/formatters/base_formatter'
require_relative 'spec/formatters/custom_formatter'
require_relative 'spec/support/db_helper'
require 'json'

class AnalysisJob < ApplicationJob
  queue_as :default
  attr_accessor :output_hash

  def perform(*args)
    logger.info "Job run started"
    job = Job.create(status: :running)

    RSpec::world.reset
    RSpec.reset
    RSpec.clear_examples

    custom_formatter = CspmFormatter.new(StringIO.new)
    custom_reporter  = RSpec::Core::Reporter.new(custom_formatter)
    options = []
    options << Dir['controls/**/controls_spec.rb']
    options << '-fCspmFormatter'
    RSpec::Core::Runner.run(options)

    results = JSON.parse(File.read('/tmp/results') )

    RSpec.clear_examples
    RSpec::world.reset
    RSpec.reset
  
    job.complete!
    logger.info "Job run ended"
  end
end

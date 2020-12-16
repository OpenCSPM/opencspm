# frozen_string_literal: true

namespace :findings do
  desc 'Generate Darkbit findings.json - run from [worker]'
  task generate: :environment do
    check_environment
    prepare_jobs
    generate_findings
  end

  PACK_BASE_DIR = 'controls/**/config.yaml'
  RESULTS_FILE = '/tmp/results'
  OUTPUT_FILE = './tmp/rawfindings.json'
  @results = []

  # check that we're running in the correct environment
  def check_environment
    puts 'Checking environment...'

    unless Socket.gethostname == 'worker'
      puts "\n[ERROR] - I need to run on the \x1b[32m[worker]\x1b[0m container.\n"
      exit 1
    end

    # result file is present
    unless File.exist?(RESULTS_FILE)
      puts "\n[ERROR] - missing results file \"#{RESULTS_FILE}\"\n"
      puts "Did you run \x1b[35mbundle exec rails batch:import\x1b[0m first?"
      exit 1
    end

    @results = JSON.parse(File.read(RESULTS_FILE))

    # results file parsed with non-zero count
    return if @results.count.positive?

    puts "\n[ERROR] - zero results found\n"
    puts "Did you run \x1b[35mbundle exec rails batch:import\x1b[0m first?"
    exit 1
  end

  # force an analysis job (kill any running jobs, or ours won't run)
  def prepare_jobs
    puts 'Preparing jobs...'

    Job.running.map(&:complete!)
    guid = "manual-#{Digest::UUID.uuid_v5(Digest::UUID::OID_NAMESPACE, Time.now.utc.to_s)}"
    puts 'Starting analysis job...'
    AnalysisJob.new.perform(guid: guid)
    Job.running.map(&:complete!)
  end

  def generate_findings
    puts 'Generating findings...'

    controls = []
    raw_results = {
      summary: {},
      version: '4.0.0',
      results: []
    }

    # load control packs
    Dir[PACK_BASE_DIR].each do |file|
      next if file.starts_with?('controls/_')

      controls.push(JSON.parse(YAML.safe_load(File.read(file)).to_json, object_class: OpenStruct).controls)
    end

    # flatten
    controls = controls.flatten

    # controls parsed with non-zero count
    unless controls.count.positive?
      puts "\n[ERROR] - zero controls found\n"
      puts "Did you enable any \x1b[35mcontrol packs\x1b[0m?"
      exit 1
    end

    # iterate over results, push onto raw_results
    @results.each_with_index do |result, idx|
      cid = result['control_id']
      ctrl = controls.find { |c| c.id == cid }

      unless ctrl
        puts "\n[ERROR] - missing control reference!\n"
        puts "Can't find control: \x1b[35m#{cid}\x1b[0m"

        exit 1
      end

      puts "Finding #{idx + 1} - #{cid}"

      raw_results[:results].push({
                                   version: '4',
                                   control: cid,
                                   finding: idx + 1,
                                   platform: ctrl.platform,
                                   category: ctrl.category,
                                   resource: ctrl.resource,
                                   title: ctrl.title,
                                   description: ctrl.description,
                                   validation: ctrl.validation,
                                   remediation: ctrl.remediation,
                                   severity: ctrl.impact ? ctrl.impact / 10.0 : 0.999,
                                   effort: ctrl.effort ? ctrl.effort / 10.0 : 0.999,
                                   resources: result['resources'].map do |r|
                                                {
                                                  resource: r['name'],
                                                  status: r['status']
                                                }
                                              end,
                                   references: ctrl.refs.map do |r|
                                                 {
                                                   text: r.text,
                                                   url: r.url,
                                                   ref: 'link'
                                                 }
                                               end,
                                   result: {
                                     status: result['resources'].filter { |r| r['status'] == 'failed' }.length.positive? ? 'failed' : 'passed',
                                     passed: result['resources'].filter { |r| r['status'] == 'passed' }.count,
                                     total: result['resources'].count
                                   }
                                 })
    end

    # write raw findings
    File.open(OUTPUT_FILE, 'w') { |file| file.write(raw_results.to_json) }
    puts "\n\nWrote raw findings to \x1b[32m#{OUTPUT_FILE}\x1b[0m\n\n"
  end
end

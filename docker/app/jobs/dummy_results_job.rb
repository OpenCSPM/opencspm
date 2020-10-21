class DummyResultsJob < ApplicationJob
  queue_as :default

  CONTROLS_FILE = './controls/opencspm-darkbit-demo-controls/config.yaml'.freeze
  ALWAYS_FAILING_RESOURCES = {
    'demo-1': 'container.googleapis.com/projects/demo1-bad/locations/us-central1/clusters/prod-cluster1',
    'demo-3': 'container.googleapis.com/projects/demo1-bad/locations/us-central1/clusters/prod-cluster1',
    'demo-4': 'container.googleapis.com/projects/demo1-bad/locations/us-central1/clusters/prod-cluster1/nodepools/default-pool',
    'demo-5': 'container.googleapis.com/projects/demo1-bad/locations/us-central1/clusters/prod-cluster1/nodepools/default-pool',
    'demo-6': 'container.googleapis.com/projects/demo1-bad/locations/us-central1/clusters/prod-cluster1',
    'demo-7': '207070077834-compute@developer.gserviceaccount.com'
  }.freeze
  RECENT_FAILING_RESOURCES = {
    'demo-2': 'container.googleapis.com/projects/demo1-bad/locations/us-central1/clusters/prod-cluster1/api/v1/namespaces/default/serviceaccounts/default'
  }.freeze

  def perform(days_ago)
    # dummy timestamp
    timestamp = days_ago.days.ago.utc.to_s

    # Shared GUID
    guid = Digest::UUID.uuid_v5(Digest::UUID::OID_NAMESPACE, Time.now.utc.to_s)

    logger.info("#{guid} Dummy Results job started")

    # Track the job
    job = Job.create(status: :running, kind: :run, guid: guid)

    yaml = YAML.load(File.read(CONTROLS_FILE))
    json = JSON.parse(yaml.to_json, object_class: OpenStruct)

    json.controls.each do |c|
      control = Control.find_by(control_pack: json.id, control_id: c.id)

      next unless control

      resources = []

      # if timestamp < 0.days.ago, resources failed = fail_always
      if days_ago
        if ALWAYS_FAILING_RESOURCES[c.id.to_sym]
          resources.push(ALWAYS_FAILING_RESOURCES[c.id.to_sym])
        end
      end

      # if timestamp > 30.days ago, resources failed = fail_always + fail_recent
      if days_ago < 31
        if RECENT_FAILING_RESOURCES[c.id.to_sym]
          resources.push(RECENT_FAILING_RESOURCES[c.id.to_sym])
        end
      end

      # p "pack: #{json.id}, id: #{control.id}"

      resources_failed = resources.length
      resources_total = 3

      result_hash = {
        status: resources_failed > 0 ? -1 : 1,
        resources_failed: resources_failed,
        resources_total: resources_total
      }

      control.update(result_hash)

      new_result = Result.create({ job: job, control: control, data: result_hash, observed_at: timestamp })

      next unless new_result

      #
      # Find or create nested resources for the control
      #
      resources.each do |r|
        resource = Resource.find_or_create_by(name: r)
        new_result.issues.create(resource: resource, status: 'failed')
      end
    end

    # Track the job
    job.complete!

    logger.info("#{guid} Dummy Results job finished")
  end
end

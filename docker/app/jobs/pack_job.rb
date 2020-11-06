#
# Import Controls from Control Packs
#
class PackJob < ApplicationJob
  queue_as :default
  # not supported by sidekiq-cron
  # sidekiq_options retry: 5

  PACK_BASE_DIR = 'controls/**/config.yaml'.freeze

  def perform
    logger.info('Control pack import job started')

    Dir['controls/**/config.yaml'].each do |file|
      # skip directories prefixed with an underscore (e.g. test/dev controls)
      next if file.starts_with?('controls/_')

      control_pack = JSON.parse(YAML.load(File.read(file)).to_json, object_class: OpenStruct)

      control_pack&.controls&.each do |control|
        puts "Control: #{control_pack.id} - #{control.id}"
        res = Control.find_or_create_by(control_pack: control_pack.id, control_id: control.id)
        res.tags.destroy_all

        control&.tags&.map do |tag|
          if tag.class == OpenStruct
            tag.to_h.keys.each do |k|
              # top level of a nested tag set
              Tagging.create(control: res, tag: Tag.find_or_create_by(name: k.downcase), primary: true)

              # secondary tags
              tag.send(k).to_a.each do |t|
                res.tags << Tag.find_or_create_by(name: t.downcase)
              end
            end
          end

          # standalone tag
          if tag.class == String
            Tagging.create(control: res, tag: Tag.find_or_create_by(name: tag.downcase), primary: true)
          end
        end

        res.update(
          guid: Digest::UUID.uuid_v5(Digest::UUID::OID_NAMESPACE, control_pack.id + control.id),
          control_pack: control_pack.id,
          control_id: control.id,
          title: control.title,
          description: control.description,
          impact: control.impact,
          validation: control.validation,
          remediation: control.remediation,
          refs: control.refs
        )
      end
    end

    logger.info('Control pack import job finished')

    #
    # On first run, execute a full load/analysis job
    #
    RunnerJob.perform_later unless Issue.count > 0
  end
end

# frozen_string_literal: true

#
# Import Controls from Control Packs
#
class PackJob < ApplicationJob
  queue_as :default
  # not supported by sidekiq-cron
  # sidekiq_options retry: 5

  PACK_BASE_DIR = 'controls/**/config.yaml'

  def perform
    logger.info('Control pack import job started')

    Dir[PACK_BASE_DIR].each do |file|
      # skip directories prefixed with an underscore (e.g. test/dev controls)
      next if file.starts_with?('controls/_')

      control_pack = JSON.parse(YAML.load(File.read(file)).to_json, object_class: OpenStruct)

      control_pack&.controls&.each do |control|
        puts "loaded control: #{control_pack.id} - #{control.id}"
        res = Control.find_or_create_by(control_pack: control_pack.id, control_id: control.id)

        existing_tags = res.tags.map(&:name).uniq
        new_tags = []

        # create new tags for primary and secondary tags
        # if they don't exist already
        control&.tags&.map do |tag|
          if tag.class == OpenStruct
            # top level of a nested tag set
            tag.to_h.keys.each do |k|
              _tag = k.to_s.downcase

              new_tags << _tag

              unless existing_tags.include?(_tag)
                Tagging.create(control: res, tag: Tag.find_or_create_by(name: _tag), primary: true)
              end

              # secondary tags
              tag.send(k).to_a.each do |t|
                _tag = t.to_s.downcase

                new_tags << _tag

                res.tags << Tag.find_or_create_by(name: _tag) unless existing_tags.include?(_tag)
              end
            end
          end

          # standalone tag
          if tag.class == String
            _tag = tag.to_s.downcase

            new_tags << _tag

            unless existing_tags.include?(_tag)
              Tagging.create(control: res, tag: Tag.find_or_create_by(name: _tag), primary: true)
            end
          end
        end

        # delete stale tags
        stale_tags = existing_tags - new_tags.uniq

        unless stale_tags.empty?
          taggings = res.tags.where(name: stale_tags).pluck(:tag_id)
          res.taggings.where(tag_id: taggings).destroy_all
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

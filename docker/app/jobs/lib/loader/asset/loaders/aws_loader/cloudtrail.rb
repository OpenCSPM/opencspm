# frozen_string_literal: true

#
# Load CloudTrail assets into RedisGraph
#
# Each method returns an array of Cypher queries
#
class AWSLoader::CloudTrail < GraphDbLoader
  def cloud_trail
    node = 'AWS_CLOUDTRAIL_TRAIL'

    q = []

    # trail node
    q.push(_upsert({ node: node, id: @name }))

    # trail status
    if @data.status
      opts = { node: node, id: @name, data: @data.status }

      q.push(_append(opts))
    end

    # s3 logging bucket
    #
    # note: multi-region trails will create multiple relationships,
    # one per region; this is expected
    if @data.s3_bucket_name
      bucket = "arn:aws:s3:::#{@data.s3_bucket_name}"

      opts = {
        node: 'AWS_S3_BUCKET',
        id: bucket
      }

      q.push(_merge(opts))

      # trail -> s3_bucket
      opts = {
        from_node: 'AWS_CLOUDTRAIL_TRAIL',
        from_name: @name,
        to_node: 'AWS_S3_BUCKET',
        to_name: bucket,
        relationship: 'LOGS_TO_BUCKET'
      }

      q.push(_link(opts))
    end

    @data&.event_selectors&.event_selectors&.each_with_index do |es, i|
      # trail -> event_selector
      opts = {
        parent_node: 'AWS_CLOUDTRAIL_TRAIL',
        parent_name: @name,
        child_node: 'AWS_CLOUDTRAIL_EVENT_SELECTOR',
        child_name: "#{@name}/event_selector_#{i}",
        relationship: 'HAS_EVENT_SELECTOR',
        relationship_attributes: {
          read_write_type: es.read_write_type,
          include_management_events: es.include_management_events,
          exclude_management_event_sources: es.exclude_management_event_sources.any?,
          include_s3_data_resources: es&.data_resources&.map { |x| x.type == 'AWS::S3::Object' && x.values.join(',') == 'arn:aws:s3' }.any?
        },
        headless: true
      }

      q.push(_upsert_and_link(opts))

      es&.data_resources&.each do |dr|
        [*dr.values].each do |v|
          # event_selector -> data_resource
          opts = {
            parent_node: 'AWS_CLOUDTRAIL_EVENT_SELECTOR',
            parent_name: "#{@name}/event_selector_#{i}",
            child_node: 'AWS_CLOUDTRAIL_DATA_RESOURCE',
            child_name: v,
            relationship: 'HAS_DATA_RESOURCE',
            relationship_attributes: { type: dr.type },
            headless: true
          }

          q.push(_upsert_and_link(opts))
        end
      end
    end

    q
  end
end

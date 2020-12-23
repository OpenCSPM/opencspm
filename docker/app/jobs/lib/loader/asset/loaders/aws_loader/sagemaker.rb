# frozen_string_literal: true

#
# Load SageMaker assets into RedisGraph
#
# Each method returns an array of Cypher queries
#
class AWSLoader::SageMaker < GraphDbLoader
  def notebook_instance
    node = 'AWS_SAGEMAKER_NOTEBOOK'
    q = []

    # notebook node
    q.push(_upsert({ node: node, id: @name }))

    q
  end

  def endpoint
    node = 'AWS_SAGEMAKER_ENDPOINT'
    q = []

    # endpoint node
    q.push(_upsert({ node: node, id: @name }))

    # data_capture_config
    if @data.data_capture_config
      node = 'AWS_SAGEMAKER_DATA_CAPTURE_CONFIG'
      name = "#{@name}/data_capture_config"

      opts = {
        parent_node: 'AWS_SAGEMAKER_ENDPOINT',
        parent_name: @name,
        child_node: node,
        child_name: name,
        relationship: 'HAS_DATA_CAPTURE_CONFIG',
        relationship_attributes: { enabled: @data.data_capture_config.enable_capture.to_s },
        headless: true
      }

      # create a headless data_capture_config node
      q.push(_upsert_and_link(opts))

      # then add the data_capture_config attributes
      q.push(_append({
                       node: node,
                       id: name,
                       data: @data.data_capture_config
                     }))
    end

    q
  end
end

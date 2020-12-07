#
# Load AWS_IAM_POLICY nodes
#
class AWSLoader::IAM < GraphDbLoader
  def policy
    node = 'AWS_IAM_POLICY'
    q = []

    # policy node
    q.push(_upsert({ node: node, id: @name }))

    # policy documents
    @data&.policy_version_list&.each_with_index do |policy|
      if policy.is_default_version
        policy_name = @data.policy_name
        policy_arn = @data.arn

        policy&.document&.Statement&.each_with_index do |statement, i|
          statement_name = "#{policy_arn}/statement-#{i}"

          # statement -> policy
          opts = {
            parent_node: 'AWS_IAM_POLICY',
            parent_name: policy_arn,
            child_node: 'AWS_IAM_POLICY_STATEMENT',
            child_name: statement_name,
            relationship: 'HAS_STATEMENT',
            relationship_attributes: { effect: statement.Effect }
          }

          q.push(_upsert_and_link(opts))

          # statement Resources
          resources = [*statement.Resource]
          resources.each do |resource|
            # resource -> statement
            opts = {
              parent_node: 'AWS_IAM_POLICY_STATEMENT',
              parent_name: statement_name,
              child_node: 'AWS_IAM_POLICY_RESOURCE',
              child_name: resource,
              relationship: 'HAS_RESOURCE'
            }

            q.push(_upsert_and_link(opts))
          end

          # statement Actions
          actions = [*statement.Action]
          actions.each do |action|
            action_name = action

            # action -> statement
            opts = {
              parent_node: 'AWS_IAM_POLICY_STATEMENT',
              parent_name: statement_name,
              child_node: 'AWS_IAM_POLICY_ACTION',
              child_name: action_name,
              relationship: 'HAS_ACTION'
            }

            q.push(_upsert_and_link(opts))
          end
        end
      end
    end

    q
  end
end

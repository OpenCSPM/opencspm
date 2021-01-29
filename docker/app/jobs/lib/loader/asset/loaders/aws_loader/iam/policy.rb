# frozen_string_literal: true

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

        # policy statements
        next unless policy&.document&.respond_to?(:Statement) # document is valid JSON

        policy&.document&.Statement&.each_with_index do |statement, i|
          statement_name = "#{policy_arn}/statement-#{i}"

          # statement -> policy
          opts = {
            parent_node: 'AWS_IAM_POLICY',
            parent_name: policy_arn,
            child_node: 'AWS_IAM_POLICY_STATEMENT',
            child_name: statement_name,
            relationship: 'HAS_STATEMENT',
            relationship_attributes: { sid: statement.Sid, effect: statement.Effect },
            headless: true
          }

          q.push(_upsert_and_link(opts))

          # statement Resources
          resources = [*statement.Resource]
          resources.each do |resource|
            # resource -> statement
            opts = {
              node: 'AWS_IAM_POLICY_RESOURCE',
              id: resource,
              headless: true
            }

            q.push(_merge(opts))

            # statement Actions
            actions = [*statement.Action]
            actions.each do |action|
              action_name = action

              # action -> statement
              opts = {
                from_node: 'AWS_IAM_POLICY_STATEMENT',
                from_name: statement_name,
                to_node: 'AWS_IAM_POLICY_RESOURCE',
                to_name: resource,
                relationship: 'HAS_ACTION',
                relationship_attributes: { action: action_name, effect: statement.Effect },
                headless: true
              }

              q.push(_link(opts))
            end
          end
        end
      end
    end

    q
  end
end

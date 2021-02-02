# frozen_string_literal: true

#
# Load SNS assets into RedisGraph
#
# Each method returns an array of Cypher queries
#
class AWSLoader::SNS < GraphDbLoader
  def topic
    node = 'AWS_SNS_TOPIC'
    q = []

    # topic node
    q.push(_upsert({ node: node, id: @name }))

    # topic policy
    if @data.policy
      policy_arn = "#{@data.arn}/policy"

      # statement -> policy
      opts = {
        parent_node: node,
        parent_name: @name,
        child_node: 'AWS_SNS_TOPIC_POLICY',
        child_name: policy_arn,
        relationship: 'HAS_POLICY'
      }

      q.push(_upsert_and_link(opts))
    end

    # topic policy statements
    if @data.policy&.Statement
      @data.policy.Statement.each_with_index do |statement, i|
        statement_name = "#{@data.arn}/statement-#{i}"

        # statement -> policy
        opts = {
          parent_node: 'AWS_SNS_TOPIC_POLICY',
          parent_name: policy_arn,
          child_node: 'AWS_SNS_TOPIC_POLICY_STATEMENT',
          child_name: statement_name,
          relationship: 'HAS_STATEMENT',
          relationship_attributes: { effect: statement.Effect },
          headless: true
        }

        q.push(_upsert_and_link(opts))

        # statement Resources
        resources = [*statement.Resource]
        resources.each do |resource|
          # resource -> statement
          opts = {
            parent_node: 'AWS_SNS_TOPIC_POLICY_STATEMENT',
            parent_name: statement_name,
            child_node: 'AWS_SNS_TOPIC_POLICY_RESOURCE',
            child_name: resource,
            relationship: 'HAS_RESOURCE',
            headless: true
          }

          q.push(_upsert_and_link(opts))

          # statement Actions
          actions = [*statement.Action]
          actions.each do |action|
            action_name = action

            # action -> statement
            opts = {
              from_node: 'AWS_SNS_TOPIC_POLICY_STATEMENT',
              from_name: statement_name,
              to_node: 'AWS_SNS_TOPIC_POLICY_RESOURCE',
              to_name: resource,
              relationship: 'HAS_ACTION',
              relationship_attributes: { action: action_name, effect: statement.Effect },
              headless: true
            }

            q.push(_link(opts))
          end
        end

        # statement Principals
        principals = [*statement.Principal]
        principals.each do |principal|
          # put "*" into a hash pair, so the rest of the parsing works
          principal = {any: '*'} if principal == '*'

          principal.each_pair do |principal_pair|
            principal_name = principal_pair[0].to_s
            values = [*principal_pair[1]]

            values.each do |value|
              opts = {
                parent_node: 'AWS_SNS_TOPIC_POLICY_STATEMENT',
                parent_name: statement_name,
                child_node: 'AWS_SNS_TOPIC_POLICY_PRINCIPAL',
                child_name: principal_name,
                relationship: 'HAS_PRINCIPAL',
                relationship_attributes: { value: value },
                headless: true
              }

              q.push(_upsert_and_link(opts))
            end
          end
        end

        # statement Conditions
        conditions = [*statement.Condition]
        conditions.each do |condition|
          condition.each_pair do |condition_pair|
            operator = condition_pair[0].to_s
            values = [*condition_pair[1]]

            values.each do |value|
              # iterate over the struct - e.g. <RecursiveOpenStruct aws:SecureTransport="false">
              # k: "aws:SecureTransport"
              # v: "false"
              value.each_pair do |k, v|
                # condition -> statement
                opts = {
                  parent_node: 'AWS_SNS_TOPIC_POLICY_STATEMENT',
                  parent_name: statement_name,
                  child_node: 'AWS_SNS_TOPIC_POLICY_CONDITION',
                  child_name: k,
                  relationship: 'HAS_CONDITION',
                  relationship_attributes: { operator: operator, value: v },
                  headless: true
                }

                q.push(_upsert_and_link(opts))
              end
            end
          end
        end
      end
    end

    # TODO: map AWS_SNS_SUBSCRIPTIONs
    q
  end
end

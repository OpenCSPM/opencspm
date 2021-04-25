# frozen_string_literal: true

#
# Load Lambda assets into RedisGraph
#
# Each method returns an array of Cypher queries
#
class AWSLoader::Lambda < GraphDbLoader
  def function
    node = 'AWS_LAMBDA_FUNCTION'
    q = []

    # function node
    q.push(_upsert({ node: node, id: @name }))

    # vpc
    q.push(_append({
                     node: node,
                     id: @name,
                     data: {
                       vpc_id: @data&.vpc_config&.vpc_id || 'none'
                     }
                   }))

    # TODO: map to IAM_ROLE (assumes role)
    # TODO: map to AWS_VPC
    # TODO: map to AWS_SUBNET
    # TODO: map to AWS_SECURITY_GROUP

    # function policy
    if @data.policy
      policy_arn = "#{@data.arn}/policy"

      # statement -> policy
      opts = {
        parent_node: node,
        parent_name: @name,
        child_node: 'AWS_LAMBDA_FUNCTION_POLICY',
        child_name: policy_arn,
        relationship: 'HAS_POLICY'
      }

      q.push(_upsert_and_link(opts))
    end

    # function policy statements
    if @data.policy&.Statement
      @data.policy.Statement.each_with_index do |statement, i|
        statement_name = "#{@data.arn}/statement-#{i}"

        # statement -> policy
        opts = {
          parent_node: 'AWS_LAMBDA_FUNCTION_POLICY',
          parent_name: policy_arn,
          child_node: 'AWS_LAMBDA_FUNCTION_POLICY_STATEMENT',
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
            parent_node: 'AWS_LAMBDA_FUNCTION_POLICY_STATEMENT',
            parent_name: statement_name,
            child_node: 'AWS_LAMBDA_FUNCTION_POLICY_RESOURCE',
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
              from_node: 'AWS_LAMBDA_FUNCTION_POLICY_STATEMENT',
              from_name: statement_name,
              to_node: 'AWS_LAMBDA_FUNCTION_POLICY_RESOURCE',
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
                parent_node: 'AWS_LAMBDA_FUNCTION_POLICY_STATEMENT',
                parent_name: statement_name,
                child_node: 'AWS_LAMBDA_FUNCTION_POLICY_PRINCIPAL',
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
                  parent_node: 'AWS_SQS_QUEUE_POLICY_STATEMENT',
                  parent_name: statement_name,
                  child_node: 'AWS_SQS_QUEUE_POLICY_CONDITION',
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

    q
  end

  def layer
    node = 'AWS_LAMBDA_LAYER'
    q = []

    # layer node
    q.push(_upsert({ node: node, id: @name }))

    # TODO: map to AWS_LAMBDA_FUNCTION

    q
  end
end

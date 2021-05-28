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

    # vpc node and relationship
    if @data.vpc_id
      opts = {
        parent_node: node,
        parent_name: @name,
        child_node: 'AWS_VPC',
        child_name: @data.vpc_id,
        relationship: 'MEMBER_OF_VPC'
      }

      q.push(_upsert_and_link(opts))
    end

    # subnet and relationship
    if @data.subnet_id
      opts = {
        parent_node: node,
        parent_name: @name,
        child_node: 'AWS_SUBNET',
        child_name: @data.subnet_id,
        relationship: 'IN_SUBNET'
      }

      q.push(_upsert_and_link(opts))
    end

    # TODO: map to IAM_ROLE (assumes role)
    # TODO: map to AWS_VPC (review lines 17 - 27, 176 - 181)
    # TODO: map to AWS_SUBNET (review lines 29 - 40, 183 - 204)
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

  def vpc
    q = []

    # vpc node
    q.push(_upsert({ node: 'AWS_VPC', id: @name }))
  end

  def subnet
    node = 'AWS_SUBNET'
    q = []

    # use subnet_id instead of ARN
    q.push(_upsert({ node: node, id: @data.subnet_id }))

    # vpc node and relationship
    if @data.vpc_id
      opts = {
        parent_node: node,
        parent_name: @data.subnet_id,
        child_node: 'AWS_VPC',
        child_name: @data.vpc_id,
        relationship: 'MEMBER_OF_VPC'
      }

      q.push(_upsert_and_link(opts))
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

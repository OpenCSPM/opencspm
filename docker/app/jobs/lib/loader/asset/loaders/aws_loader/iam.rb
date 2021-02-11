# frozen_string_literal: true

#
# Load IAM assets into RedisGraph
#
class AWSLoader::IAM < GraphDbLoader
  def account_summary
    node = 'AWS_IAM_ACCOUNT_SUMMARY'
    q = []

    # account_summary node
    q.push(_upsert({ node: node, id: @name }))
  end

  def password_policy
    node = 'AWS_IAM_PASSWORD_POLICY'
    q = []

    # password_policy node
    q.push(_upsert({ node: node, id: @name }))
  end

  def credential_report
    node = 'AWS_IAM_USER'
    q = []

    @data&.content&.each do |user|
      id = user.delete_field('arn')

      q.push(_merge({ node: node, id: id }))

      opts = {
        node: node,
        id: id,
        data: user
      }

      q.push(_append(opts))
    end

    q
  end

  def instance_profile
    node = 'AWS_EC2_IAM_PROFILE'
    q = []

    # instance_profile node
    q.push(_upsert({ node: node, id: @name }))

    @data.roles.each do |role|
      # role -> profile
      opts = {
        parent_node: node,
        parent_name: @name,
        child_node: 'AWS_EC2_IAM_PROFILE_ROLE',
        child_name: role.arn,
        relationship: 'HAS_ROLE'
      }

      q.push(_upsert_and_link(opts))

      policy_arn = "#{role.arn}/policy"

      if role.assume_role_policy_document
        # policy -> role
        opts = {
          parent_node: 'AWS_EC2_IAM_PROFILE_ROLE',
          parent_name: role.arn,
          child_node: 'AWS_EC2_IAM_PROFILE_ROLE_POLICY',
          child_name: policy_arn,
          relationship: 'HAS_POLICY'
        }

        q.push(_upsert_and_link(opts))
      end

      next unless role&.assume_role_policy_document&.Statement

      role.assume_role_policy_document.Statement.each_with_index do |statement, i|
        statement_name = "#{policy_arn}/statement-#{i}"

        # statement -> policy
        opts = {
          parent_node: 'AWS_EC2_IAM_PROFILE_ROLE_POLICY',
          parent_name: policy_arn,
          child_node: 'AWS_EC2_IAM_PROFILE_ROLE_POLICY_STATEMENT',
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
            parent_node: 'AWS_EC2_IAM_PROFILE_ROLE_POLICY_STATEMENT',
            parent_name: statement_name,
            child_node: 'AWS_EC2_IAM_PROFILE_ROLE_POLICY_RESOURCE',
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
              from_node: 'AWS_EC2_IAM_PROFILE_ROLE_POLICY_STATEMENT',
              from_name: statement_name,
              to_node: 'AWS_EC2_IAM_PROFILE_ROLE_POLICY_RESOURCE',
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
                parent_node: 'AWS_EC2_IAM_PROFILE_ROLE_POLICY_STATEMENT',
                parent_name: statement_name,
                child_node: 'AWS_EC2_IAM_PROFILE_ROLE_POLICY_PRINCIPAL',
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
                  parent_node: 'AWS_EC2_IAM_PROFILE_ROLE_POLICY_STATEMENT',
                  parent_name: statement_name,
                  child_node: 'AWS_EC2_IAM_PROFILE_ROLE_POLICY_CONDITION',
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
end

# frozen_string_literal: true

#
# Load S3 assets into RedisGraph
#
# Each method returns an array of Cypher queries
#
class AWSLoader::S3 < GraphDbLoader
  def bucket
    node = 'AWS_S3_BUCKET'
    q = []

    # bucket node
    q.push(_upsert({ node: node, id: @name }))

    # owner
    if @data
      opts = {
        node: node,
        id: @name,
        data: {
          owner_display_name: @data&.acl&.owner&.display_name,
          owner_id: @data&.acl&.owner&.id,
          is_public: @data&.public&.is_public || false,
          is_encrypted_at_rest: @data&.encryption&.rules&.count&.positive? || false,
          versioning_enabled: @data&.versioning&.status == 'Enabled' || false,
          mfa_deletion: @data&.versioning&.mfa_delete == 'Enabled' || false,
          logging_bucket: @data&.logging&.target_bucket || false
        }
      }

      q.push(_append(opts))
    end

    # bucket policy
    if @data.policy
      policy_arn = @data.arn.to_s

      # policy -> bucket
      opts = {
        parent_node: 'AWS_S3_BUCKET',
        parent_name: @name,
        child_node: 'AWS_S3_BUCKET_POLICY',
        child_name: policy_arn,
        relationship: 'HAS_POLICY'
      }

      q.push(_upsert_and_link(opts))
    end

    # bucket policy statements
    if @data.policy&.Statement
      @data.policy.Statement.each_with_index do |statement, i|
        statement_name = "#{@data.arn}/statement-#{i}"

        # statement -> policy
        opts = {
          parent_node: 'AWS_S3_BUCKET_POLICY',
          parent_name: policy_arn,
          child_node: 'AWS_S3_BUCKET_POLICY_STATEMENT',
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
            parent_node: 'AWS_S3_BUCKET_POLICY_STATEMENT',
            parent_name: statement_name,
            child_node: 'AWS_S3_BUCKET_POLICY_RESOURCE',
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
              from_node: 'AWS_S3_BUCKET_POLICY_STATEMENT',
              from_name: statement_name,
              to_node: 'AWS_S3_BUCKET_POLICY_RESOURCE',
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
                parent_node: 'AWS_S3_BUCKET_POLICY_STATEMENT',
                parent_name: statement_name,
                child_node: 'AWS_S3_BUCKET_POLICY_PRINCIPAL',
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
                  parent_node: 'AWS_S3_BUCKET_POLICY_STATEMENT',
                  parent_name: statement_name,
                  child_node: 'AWS_S3_BUCKET_POLICY_CONDITION',
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

  # TODO: map acl grants
  # TODO: map acl policy
end

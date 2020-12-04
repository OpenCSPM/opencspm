#
# Load AWS_IAM_USER nodes
#
class AWSLoader::IAM < GraphDbLoader
  def user
    node = 'AWS_IAM_USER'
    q = []

    # user node
    q.push(_upsert({ node: node, id: @name }))

    # mfa devices and relationship
    @data&.mfa_devices&.each do |mfa|
      # mfa device node
      q.push(_upsert({
                       node: 'AWS_IAM_MFA_DEVICE',
                       id: mfa.serial_number,
                       data: mfa
                     }))

      # mfa_device -> user
      opts = {
        parent_node: 'AWS_IAM_MFA_DEVICE',
        parent_name: mfa.serial_number,
        child_node: node,
        child_name: @name,
        relationship: 'HAS_MFA_DEVICE',
        relationship_attributes: { virtual_mfa_token: false }
      }

      q.push(_upsert_and_link(opts))
    end

    # inline policies
    @data&.user_policy_list&.each do |policy|
      policy_name = policy.policy_name

      # inline policy node
      q.push(_upsert({
                       node: 'AWS_IAM_POLICY',
                       id: policy_name,
                       data: { inline: true }
                     }))

      # policy -> user
      opts = {
        parent_node: node,
        parent_name: @name,
        child_node: 'AWS_IAM_POLICY',
        child_name: policy_name,
        relationship: 'HAS_INLINE_POLICY',
        relationship_attributes: { inline: true, managed: false }
      }

      q.push(_upsert_and_link(opts))

      # policy statements
      policy&.policy_document&.Statement&.each_with_index do |statement, i|
        statement_name = "#{policy_name.downcase}-#{i}"

        # inline policy statement node
        q.push(_upsert({
                         node: 'AWS_IAM_POLICY_STATEMENT',
                         id: statement_name,
                         data: statement
                       }))

        # statement -> policy
        opts = {
          parent_node: 'AWS_IAM_POLICY',
          parent_name: policy_name,
          child_node: 'AWS_IAM_POLICY_STATEMENT',
          child_name: statement_name,
          relationship: 'HAS_STATEMENT',
          relationship_attributes: { effect: statement.Effect, resource: statement.Resource }
        }

        q.push(_upsert_and_link(opts))

        # statement actions
        statement&.Action&.each do |action|
          action_name = action

          # inline policy statement node
          q.push(_upsert({
                           node: 'AWS_IAM_POLICY_ACTION',
                           id: action_name
                         }))

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

    # TODO: map ssh_keys
    # TODO: map attached_managed_policies
    q
  end
end

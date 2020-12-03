#
# Load IAM assets into RedisGraph
#
# Each method returns an array of Cypher queries
#
class AWSLoader::IAM < GraphDbLoader
  def user
    node = 'AWS_IAM_USER'
    q = []

    # user node
    q.push(_upsert({ node: node, id: @name }))

    # mfa devices and relationship
    @data.mfa_devices.each do |mfa|
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
    @data.user_policy_list.each do |policy|
      # inline policy node
      q.push(_upsert({
                       node: 'AWS_IAM_POLICY',
                       id: policy.policy_name,
                       data: { inline: true }
                     }))

      # policy -> user
      opts = {
        parent_node: node,
        parent_name: @name,
        child_node: 'AWS_IAM_POLICY',
        child_name: policy.policy_name,
        relationship: 'HAS_INLINE_POLICY',
        relationship_attributes: { inline: true, managed: false }
      }

      q.push(_upsert_and_link(opts))

      # policy statements
      policy&.policy_document.Statement.each_with_index do |statement, i|
        # inline policy statement node
        q.push(_upsert({
                         node: 'AWS_IAM_POLICY_STATEMENT',
                         id: "#{policy.policy_name.downcase}-#{i}",
                         data: statement
                       }))

        # statement -> policy
        opts = {
          parent_node: 'AWS_IAM_POLICY',
          parent_name: policy.policy_name,
          child_node: 'AWS_IAM_POLICY_STATEMENT',
          child_name: "#{policy.policy_name.downcase}-#{i}",
          relationship: 'HAS_STATEMENT',
          relationship_attributes: {
            effect: statement.Effect,
            resource: statement.Resource
          }
        }

        q.push(_upsert_and_link(opts))
      end
    end

    # TODO: map ssh_keys
    # TODO: map user_policy_list (attached inline policies)
    # TODO: map attached_managed_policies
    q
  end

  def group
    node = 'AWS_IAM_GROUP'
    q = []

    # group node
    q.push(_upsert({ node: node, id: @name }))

    # TODO: map attached_managed_policies
    q
  end

  def role
    node = 'AWS_IAM_ROLE'
    q = []

    # role node
    q.push(_upsert({ node: node, id: @name }))

    # TODO: map attached_managed_policies
    q
  end

  def policy
    node = 'AWS_IAM_POLICY'
    q = []

    # policy node
    q.push(_upsert({ node: node, id: @name }))

    # TODO: parse policy document
    q
  end

  def managed_policy
    node = 'AWS_IAM_MANAGED_POLICY'
    q = []

    # policy node
    q.push(_upsert({ node: node, id: @name }))

    # TODO: map to account (to support multiple accounts)
    # TODO: parse policy document
    q
  end

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

  def server_certificate
    node = 'AWS_IAM_SERVER_CERTIFICATE'
    q = []

    # server_certificate node
    q.push(_upsert({ node: node, id: @name }))
  end

  #
  # MFA_DEVICE relationship is created backwards because
  # the root user is not enumerated by the IAM API. The only
  # way to know if the root user has a virtual MFA token is
  # to map the user from the MFA device.
  #
  def virtual_mfa_device
    node = 'AWS_IAM_MFA_DEVICE'
    q = []

    # virtual_mfa_device node
    q.push(_upsert({ node: node, id: @name }))

    # user node and relationship
    if @data.user
      opts = {
        parent_node: node,
        parent_name: @name,
        child_node: 'AWS_IAM_USER',
        child_name: @data.user.arn,
        relationship: 'HAS_MFA_DEVICE',
        relationship_attributes: { virtual_mfa_token: true }
      }

      q.push(_upsert_and_link(opts))
    end

    q
  end

  def credential_report
    node = 'AWS_IAM_USER'
    q = []

    @data&.content&.each do |user|
      id = user.delete_field('arn')

      opts = {
        node: node,
        id: id,
        data: user
      }

      q.push(_append(opts))
    end

    q
  end
end

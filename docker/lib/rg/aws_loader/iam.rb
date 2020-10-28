#
# Load IAM assets into RedisGraph
#
# Each method returns an array of Cypher queries
#
class AWSLoader::IAM < AwsGraphDbLoader
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

      opts = {
        parent_node: 'AWS_IAM_USER',
        parent_name: @name,
        child_node: 'AWS_IAM_MFA_DEVICE',
        child_name: mfa.serial_number,
        relationship: 'HAS_MFA_DEVICE',
        relationship_attributes: { virtual_mfa_token: false }
      }

      q.push(_upsert_and_link(opts))
    end

    # TODO: map ssh_keys
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
  # way to know if the root user has an MFA token is to map
  # the user from the MFA device.
  #
  def virtual_mfa_device
    node = 'AWS_IAM_MFA_DEVICE'
    q = []

    # virtual_mfa_device node
    q.push(_upsert({ node: node, id: @name }))

    # user node and relationship
    if @data.user
      opts = {
        parent_node: 'AWS_IAM_USER',
        parent_name: @data.user.arn,
        child_node: node,
        child_name: @name,
        relationship: 'HAS_MFA_DEVICE',
        relationship_attributes: { virtual_mfa_token: true }
      }

      q.push(_upsert_and_link(opts))
    end

    q
  end
end

#
# Load AWS_IAM_MFA_DEVICE nodes
#
class AWSLoader::IAM < GraphDbLoader
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
end

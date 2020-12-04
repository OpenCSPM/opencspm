#
# Load AWS_IAM_ROLE nodes
#
class AWSLoader::IAM < GraphDbLoader
  def role
    node = 'AWS_IAM_ROLE'
    q = []

    # role node
    q.push(_upsert({ node: node, id: @name }))

    # TODO: map attached_managed_policies
    q
  end
end

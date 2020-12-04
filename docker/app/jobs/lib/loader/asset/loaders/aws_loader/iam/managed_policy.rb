#
# Load AWS_IAM_MANAGED_POLICY nodes
#
class AWSLoader::IAM < GraphDbLoader
  def managed_policy
    node = 'AWS_IAM_MANAGED_POLICY'
    q = []

    # policy node
    q.push(_upsert({ node: node, id: @name }))

    # TODO: map to account (to support multiple accounts)
    # TODO: parse policy document
    q
  end
end

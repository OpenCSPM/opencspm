#
# Load AWS_IAM_POLICY nodes
#
class AWSLoader::IAM < GraphDbLoader
  def policy
    node = 'AWS_IAM_POLICY'
    q = []

    # policy node
    q.push(_upsert({ node: node, id: @name }))

    # TODO: parse policy document
    q
  end
end

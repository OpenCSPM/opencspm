#
# Load AWS_IAM_GROUP nodes
#
class AWSLoader::IAM < GraphDbLoader
  def group
    node = 'AWS_IAM_GROUP'
    q = []

    # group node
    q.push(_upsert({ node: node, id: @name }))

    # TODO: map attached_managed_policies
    q
  end
end

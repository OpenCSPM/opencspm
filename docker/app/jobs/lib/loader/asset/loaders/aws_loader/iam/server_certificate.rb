#
# Load AWS_IAM_SERVER_CERTIFICATE nodes
#
class AWSLoader::IAM < GraphDbLoader
  def server_certificate
    node = 'AWS_IAM_SERVER_CERTIFICATE'
    q = []

    # server_certificate node
    q.push(_upsert({ node: node, id: @name }))
  end
end

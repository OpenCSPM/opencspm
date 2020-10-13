require "sinatra"
require_relative "iam"

set :bind, "0.0.0.0"
set :port, "8080"

get "/" do
  ""
end

get "/healthz" do
  "ok"
end

get "/exportcai" do
  logger.info "IAM Export Called via Cloud Run"
  export_iam_cai
  "done"
end

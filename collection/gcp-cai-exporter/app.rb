require "sinatra"
require_relative "asset"

set :bind, "0.0.0.0"
set :port, "8080"

get "/" do
  ""
end

get "/healthz" do
  "ok"
end

get "/exportcai" do
  logger.info "CAI Export Called via Cloud Run"
  export_gcp_cai
  "done"
end

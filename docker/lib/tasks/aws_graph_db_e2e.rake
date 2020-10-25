namespace :graph do
  desc 'Deletes an loads all AWS Recon results into RedisGraph'
  task load: :environment do
    rg = Rg.new
    rg._clear_log
    rg.delete_all
    rg.create_all
  end
end

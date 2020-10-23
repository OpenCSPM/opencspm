namespace :graph do
  desc 'Loads AWS Recon results into RedisGraph'
  task create: :environment do
    rg = Rg.new
    rg.create_all
  end
end

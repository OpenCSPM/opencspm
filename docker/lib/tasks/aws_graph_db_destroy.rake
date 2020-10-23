namespace :graph do
  desc 'Deletes all AWS Recon results from RedisGraph'
  task destroy: :environment do
    rg = Rg.new
    rg.delete_all
  end
end

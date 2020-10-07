namespace :results do
  desc 'Loads 60 days of dummy results'
  task load: :environment do
    # days = 60
    days = 10

    days.times do |day|
      LoaderJob.perform_now({source_id: 1, timestamp: day.days.ago.utc.to_s })
    end
  end
end

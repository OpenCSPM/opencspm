namespace :results do
  desc 'Loads 60 days of dummy results'
  task load: :environment do
    days = 60
    # days = 10

    # count down
    (1..days).reverse_each do |day|
      DummyResultsJob.new.perform(day)
    end
  end
end

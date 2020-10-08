Rails.application.configure do
  config.lograge.enabled = true
  config.lograge.base_controller_class = 'ActionController::API'
  config.lograge.ignore_actions = ['HealthcheckController#index']

  # For debugging, re-enable original Rails verbose style logging to file
  #
  # config.lograge.keep_original_rails_log = true
  # config.lograge.logger = ActiveSupport::Logger.new "#{Rails.root}/log/#{Rails.env}.log"
end

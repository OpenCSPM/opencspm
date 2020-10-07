#
# Custom application settings
#
Rails.application.configure do
  # Set scaffold generators
  # https://evilmartians.com/chronicles/evil-front-part-1
  config.generators do |g|
    g.test_framework  :rspec,
                      fixtures: false,
                      model_specs: true,
                      view_specs: false,
                      helper_specs: false,
                      routing_specs: true,
                      request_specs: true,
                      controller_specs: false
    g.factory_bot     true
    g.stylesheets     false
    g.javascripts     false
    g.helper          false
    g.channel         assets: false
  end

  # Enable session middleware
  # (https://github.com/omniauth/omniauth#integrating-omniauth-into-your-rails-api)
  if Rails.env.production?
    config.cookie_domain = '.opencspm.org'
    config.ui_host = 'https://demo.opencspm.org'
    config.session_store :cookie_store, key: '_opencspm_session', secure: true, httponly: true, domain: config.cookie_domain
    config.hosts << config.cookie_domain
  else
    config.cookie_domain = 'localhost'
    config.ui_host = 'http://localhost:8080'
    config.session_store :cookie_store, key: '_opencspm_session'
  end
  config.middleware.use ActionDispatch::Cookies # Required for all session management
  config.middleware.use ActionDispatch::Session::CookieStore, config.session_options

  # Use Sidekiq for ActiveJob
  config.active_job.queue_adapter = :sidekiq
end

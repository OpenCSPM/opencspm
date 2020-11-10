Rails.application.config.middleware.use OmniAuth::Builder do
  # creds = RecursiveOpenStruct.new(Rails.application.credentials.config).oauth[Rails.env]

  # provider :google_oauth2, creds.google.client_id, creds.google.client_secret, { name: 'google', scope: 'userinfo.email' }
  # provider :github, creds.github.client_id, creds.github.client_secret, scope: 'user:email'

  # ensure callback is always https
  # OmniAuth.config.full_host = Rails.env.production? ? 'https://auth.opencspm.org' : 'http://localhost:5000'
  # OmniAuth.config.allowed_request_methods = [:post]
end

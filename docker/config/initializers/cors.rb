# Be sure to restart your server when you modify this file.

# Avoid CORS issues when API is called from the frontend app.
# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin AJAX requests.

# Read more: https://github.com/cyu/rack-cors

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins 'http://localhost:8000', 'https://demo.opencspm.org'

    resource '*',
             headers: :any,
             credentials: true,
             methods: %i[get post put patch delete options head]
  end
end

# https://pragmaticstudio.com/tutorials/rails-session-cookies-for-api-authentication
# Rails.application.config.action_controller.forgery_protection_origin_check = false

require_relative 'boot'

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "action_cable/engine"
require "sprockets/railtie"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Sono
  class Application < Rails::Application
    config.active_job.queue_adapter = :sidekiq

    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    # config.action_mailer.perform_caching = false
    config.action_mailer.default_url_options = {host: ENV.fetch('APP_HOST')}
    # config.action_mailer.delivery_method = :smtp
    # config.action_mailer.smtp_settings = {
    #   address: 'smtp.domain.com',
    #   user_name: ENV.fetch('MAIL_ACCOUNT'),
    #   password: ENV.fetch('MAIL_PASSWORD'),
    #   openssl_verify_mode: OpenSSL::SSL::VERIFY_NONE
    # }

    config.action_mailer.delivery_method = :sendgrid_actionmailer
    config.action_mailer.sendgrid_actionmailer_settings = {
      api_key: ENV['SENDGRID_API_KEY'],
      raise_delivery_errors: true
    }

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Don't generate system test files.
    config.generators.system_tests = nil

    config.action_mailer.default_url_options = { :host => ENV.fetch('APP_HOST') }
  end
end

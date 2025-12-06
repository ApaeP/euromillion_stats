require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

module EuromillionStats
  class Application < Rails::Application
    config.load_defaults 8.1
    config.time_zone = "Europe/Paris"
    config.i18n.available_locales = [:fr, :en]
    config.i18n.default_locale = :fr
  end
end

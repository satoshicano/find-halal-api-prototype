require_relative 'boot'

require 'rails'
require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_view/railtie'
require 'action_cable/engine'
require 'sprockets/railtie'

Bundler.require(*Rails.groups)

module FindHalalApiPrototype
  class Application < Rails::Application
    config.load_defaults 5.1
    config.generators.system_tests = nil
    config.autoload_paths += %W[#{config.root}/lib]
    config.read_encrypted_secrets = true
  end
end

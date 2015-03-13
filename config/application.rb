require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Golfer
  class Application < Rails::Application
    config.active_record.raise_in_transactional_callbacks = true
    config.assets.enabled = false

    config.middleware.use Rack::Cors do
      allow do
        origins '*'
        resource '*', :headers => :any, :methods => [:get, :post, :options, :put, :patch, :delete]
      end
    end

    # databases
    config.generators do |g|
     # g.orm :mongoid
     g.orm :active_record
    end
  end
end

require_relative './config_loader'

module FeatureDbRails
  class Railtie < Rails::Railtie
    rake_tasks do
      Dir[File.join(File.dirname(__FILE__),'tasks/*.rake')].each { |f| load f }
    end

    config.before_initialize do
      config_loader = ConfigLoader.new(Rails.root.join('config/feature_db_rails.yml').to_s, Rails.env)
      config_loader.load
    end
  end
end

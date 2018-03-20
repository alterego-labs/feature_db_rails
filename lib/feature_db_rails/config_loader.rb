require 'yaml'
require 'erb'

module FeatureDbRails
  class ConfigLoader
    def initialize(config_file_path, environment)
      @config_file_path = config_file_path
      @environment = environment
    end

    def load
      config = read_config_file
      apply_config(config)
    end

    private

    attr_reader :config_file_path, :environment

    def read_config_file
      raw_config = IO.read(config_file_path)
      config = YAML::load(ERB.new(raw_config).result) || {}
      config.fetch(environment, {})
    rescue Psych::SyntaxError => e
      raise "FeatureDbRails config file is not a valid YAML file: #{e.message}."
    rescue Errno::ENOENT => e
      raise "Cannot load FeatureDbRails config file: #{e.message}."
    end

    def apply_config(config_hash)
      FeatureDbRails.config do |config|
        config.base_db_name = config_hash['base_db_name']
        config.db_username = config_hash['db_username']
        config.db_password = config_hash['db_password']
      end
    end
  end
end

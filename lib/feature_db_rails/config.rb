module FeatureDbRails
  class Config
    attr_reader :base_db_name,
                :db_username,
                :db_password

    def self.with_base_db_name(base_db_name)
      new(base_db_name, nil, nil) 
    end

    def initialize(base_db_name, db_username, db_password)
      @base_db_name = base_db_name
      @db_username = db_username
      @db_password = db_password
    end

    def extend_by_rails_db_config(rails_db_config)
      Config.new(
        base_db_name,
        rails_db_config['username'],
        rails_db_config['password']
      )
    end
  end
end

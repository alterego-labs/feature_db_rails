require 'feature_db_rails/version'
require 'feature_db_rails/config'
require 'feature_db_rails/railtie' if defined?(Rails)
require 'yaml'

module FeatureDbRails
  BRANCH_CODE =
    `git symbolic-ref HEAD 2>/dev/null`
      .chomp
      .sub('refs/heads/', '')
      .gsub(/[\.\/\-]/, '_')

  def self.config
    @config
  end

  def self.init(database_original:)
    @config = Config.with_base_db_name(database_original)
  end

  def self.load_config
    @config = @config.extend_by_rails_db_config(
      Rails.configuration.database_configuration[Rails.env]
    )
  end

  def self.generate
    if !featured_db_enabled?
      enable_featured_db
      create_db
      copy_db_from_original
    else
      puts 'The feature DB is already enabled for the current branch!'
    end
  end

  def self.revert
    if featured_db_enabled?
      drop_feature_db
      cleanup_git_branch_config
    else
      puts 'There is no featured db which is enabled for the current branch!'
    end
  end

  def self.target_db_name(database_original)
    init(database_original: database_original)
    featured_db_enabled? ? featured_db_name : config.base_db_name
  end

  private

  def self.featured_db_enabled?
    `git config --bool branch.#{BRANCH_CODE}.database`.chomp == 'true'
  end

  def self.enable_featured_db
    `git config --bool branch.#{BRANCH_CODE}.database true`
    puts 'Provided settings for git that current branch will use feature DB...'
  end

  def self.create_db
    Rake::Task['db:create'].invoke
    puts 'Created feature DB...'
  end

  def self.copy_db_from_original
    dump_file_path = Rails.root.join('tmp/db.sql').to_s
    puts "Feature DB is called `#{featured_db_name}`"
    `mysqldump --user=#{config.db_username} --password=#{config.db_password} #{config.base_db_name} > #{dump_file_path}`
    `mysql --user=#{config.db_username} --password=#{config.db_password} #{featured_db_name} < #{dump_file_path}`
    puts 'Copied all schema and data from development DB into feature DB...'
  end

  def self.drop_feature_db
    Rake::Task['db:drop'].invoke
    puts 'Droped feature DB...'
  end

  def self.cleanup_git_branch_config
    `git config --unset --bool branch.#{BRANCH_CODE}.database`
    puts 'Cleaned up settings for git that current branch will not use feature DB...'
  end

  def self.featured_db_name
    "#{config.base_db_name}_#{BRANCH_CODE}"
  end

  def self.check_for_config
    return if config
    raise "The config is not initialized! You have to initialize the library manually! Please, read README for instructions!"
  end
end

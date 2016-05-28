require "feature_db_rails/version"

module FeatureDbRails
  def self.generate
    if can_generate_feature_db?
      provide_git_branch_config
      create_db
      copy_db_from_original
    else
      puts "Feature DB can not be generated for branch `#{detect_branch}`!"
    end
  end

  def self.revert
    drop_feature_db
    cleanup_git_branch_config
  end

  def self.db_suffix
    branch = detect_branch
    `git config --bool branch.#{branch}.database`.chomp == 'true' ? "_#{branch}" : ""
  end

  private

  def self.can_generate_feature_db?
    !['develop', 'master'].include?(detect_branch)
  end

  def self.can_revert_feature_db?
    `git config --bool branch.#{branch}.database`.chomp == 'true' 
  end

  def self.provide_git_branch_config
    `git config --bool branch.#{detect_branch}.database true`
    puts 'Provided settings for git that current branch will use feature DB...'
  end

  def self.cleanup_git_branch_config
    `git config --unset --bool branch.#{detect_branch}.database`
    puts 'Cleaned up settings for git that current branch will not use feature DB...'
  end

  def self.create_db
    Rake::Task['db:create'].invoke
    # In my case I had stored functions and views. And they do not copied during the mysqldump.
    # Also I had custom tasks to generate them and they are run before `db:migrate`. That's why I
    # added running `db:migrate` there. This some kind of special case requirement, so it must be
    # extracted in the future.
    Rake::Task['db:migrate'].invoke
    puts 'Created feature DB...'
  end

  def self.drop_feature_db
    Rake::Task['db:drop'].invoke
    puts 'Droped feature DB...'
  end

  def self.copy_db_from_original
    original_name = ENV['DEV_DB_NAME']
    new_name = "#{original_name}#{db_suffix}"
    puts "Feature DB is called `#{new_name}`"
    `mysqldump --user=#{ENV['DEV_DB_USERNAME']} --password=#{ENV['DEV_DB_PASSWORD']} #{original_name} | mysql --user=#{ENV['DEV_DB_USERNAME']} --password=#{ENV['DEV_DB_PASSWORD']} #{new_name}`
    puts 'Copied all schema and data from development DB into feature DB...'
  end

  def self.detect_branch
    `git symbolic-ref HEAD 2>/dev/null`
      .chomp
      .sub('refs/heads/', '')
      .gsub('/', '_')
  end
end


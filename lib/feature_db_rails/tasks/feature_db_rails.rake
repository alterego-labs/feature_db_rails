namespace :feature_db_rails do
  task load_config: :environment do
    FeatureDbRails.load_config
  end

  desc "Generate feature DB for current feature branch"
  task generate: [:environment, :load_config] do
    FeatureDbRails.generate
  end

  desc "Revert feature DB for current feature branch"
  task revert: [:environment, :load_config] do
    FeatureDbRails.revert
  end 
end

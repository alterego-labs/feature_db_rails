namespace :feature_db_rails do
  desc "Generate feature DB for current feature branch"
  task generate: :environment do
    FeatureDbRails.generate
  end

  desc "Revert feature DB for current feature branch"
  task revert: :environment do
    FeatureDbRails.revert
  end 
end

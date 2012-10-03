# Deployment Rake Tasks

desc 'Deploy, migrate and restart processes'
task :deploy => 'knight:deploy_and_migrate'

desc 'Simple deploy without migration'
task 'deploy:simple' => 'knight:deploy'

desc 'Deploy to staging'
task 'deploy:staging' => 'knight:deploy:staging'

namespace :knight do
  desc 'Deploy to Heroku'
  task :deploy do
    puts    'Pushing to Github...'
    system  'git push origin master'
    puts    'Deploying to Heroku production...'
    system  'git push heroku master'
  end

  namespace :deploy do
    task :staging do
      puts    'Deploying to staging...'
      system  'git push staging staging'
      puts    'Deployed to staging'
    end
  end

  desc 'Migrate the database'
  task :migrate do
    puts    'Migrating Database...'
    system  'heroku run rake db:migrate'
  end

  desc 'Migrate new seeds'
  task :seed do
    puts    'Migrating new Seeds...'
    system  'heroku run rake db:seed'
  end

  desc 'Restart processes'
  task :restart do
    puts    'Restarting Processes...'
    system  'heroku restart'
  end

  desc ':deploy, :migrate, :restart'
  task :deploy_and_migrate => [:deploy, :migrate, :restart]

  desc 'Perform serial Knight Update'
  task :update_knight do
    puts 'Processing update Knight in production...'
    system 'heroku run rails runner KnightUpdater.update_knight_serial'
  end

  desc 'Bust Caches'
  task :bust_caches do
    puts 'Busting Caches...'
    system 'heroku run rails runner Repo.bust_caches'
    system 'heroku run rails runner Category.bust_caches'
  end

  desc 'Clear away empty categories'
  task :clean_empty_categories do
    puts 'Cleaning Knight of empty categories...'
    system 'heroku run rails runner Category.clean'
  end
end

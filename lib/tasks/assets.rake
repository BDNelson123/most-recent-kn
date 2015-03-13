# Heroku hack: remove this if not using Heroku
# Purpose: to not compile assets on heroku since this is an API
Rake::Task["assets:precompile"].clear
namespace :assets do
  task 'precompile' do
      puts "Not pre-compiling assets..."
  end
end

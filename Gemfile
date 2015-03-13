source 'https://rubygems.org'

gem 'rails', '4.2.0'
gem 'mysql2', '0.3.18'
gem 'rails-api', '0.4.0'
gem 'mongoid', '4.0.0'
gem 'validates_timeliness', '3.0.14'
gem 'responders', '~> 2.0'
gem 'devise_token_auth', '0.1.31'
gem 'omniauth', '1.2.2'
gem 'omniauth-facebook', '2.0.1'
gem 'rack-cors', '0.3.1', :require => 'rack/cors'
gem 'validates_email_format_of', :git => 'git://github.com/alexdunae/validates_email_format_of.git'

group :development, :test do
  gem 'byebug'
  gem 'web-console', '~> 2.0'
  gem 'spring'
  gem 'rspec-rails', '2.14.1'
  gem 'factory_girl', '4.5.0'
  gem 'faker', '1.4.3'
  gem 'shoulda-matchers', '2.8.0'
  gem 'rest-client', '1.7.3'
  gem 'json_spec', '1.1.4'
end

group :production do
  # heroku gem for rails - remove if not using heroku
  gem 'rails_12factor'
end

ruby '2.1.5'


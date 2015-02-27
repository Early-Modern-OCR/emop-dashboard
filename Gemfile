source 'https://rubygems.org'


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.1.4'
# Use mysql as the database for Active Record
gem 'mysql2'
gem 'settingslogic'
gem 'rest-client'
gem 'whenever', require: false
gem 'rmagick', require: false
gem 'activerecord-import', '~> 0.4.1'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.3'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
gem 'therubyracer',  platforms: :ruby

# API
gem 'apipie-rails'
gem 'maruku', group: :development
gem 'versionist'

# Authentication and authorization
gem 'devise'

# Administration
gem 'activeadmin', github: 'activeadmin'

# Maintenance
gem 'turnout'

# Use jquery as the JavaScript library
gem 'jquery-rails'
gem 'jquery-ui-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/kaminarier
gem 'jbuilder', '~> 2.0'
gem 'kaminari'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', '~> 0.4.0', require: false
end

# Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
gem 'spring', group: :development

gem 'exception_notification'

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
group :development do
  gem 'capistrano', '~> 3.2.0'
  gem 'capistrano-bundler', '~> 1.1.3'
  gem 'capistrano-rails', '~> 1.1'
  gem 'rvm1-capistrano3', require: false
  gem 'capistrano-rails-collection'
end

# Use debugger
# gem 'debugger', group: [:development, :test]

group :development, :test do
  gem 'coveralls', require: false
  gem 'rspec-rails', '~> 3.0.0'
  gem 'rspec-html-matchers'
  gem 'shoulda-matchers', require: false
  gem 'factory_girl', '~> 4.0'
  gem 'database_cleaner'
  gem 'rubocop', require: false
end

group :test do
  gem "simplecov", require: false
end

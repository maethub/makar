source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }
ruby '2.5.1'

gem 'rails', '~> 5.2.3'
gem 'puma', '~> 3.11'
gem 'sass-rails', '~> 5.0'
gem 'normalize-rails'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.2'
gem 'jbuilder', '~> 2.5'
gem 'bootsnap', '>= 1.1.0', require: false
gem 'ransack'
gem 'will_paginate'
gem 'selectize-rails'
# gem 'will_paginate-bootstrap4'
gem 'simple_form'
gem 'httparty'
gem 'active_record_upsert'
gem 'activerecord-import'

# JSON Schema validation
gem 'json-schema'
gem 'codemirror-rails'

gem 'delayed_job'
gem 'delayed_job_active_record'
gem 'daemons'

gem 'semantic-ui-sass'

gem 'mbox', git: 'https://github.com/meh/ruby-mbox'
gem 'octokit'

gem 'yajl-ruby'
gem 'rubyzip'

# NLP
gem 'stopwords-filter', require: 'stopwords'
gem 'ruby-stemmer', require: 'lingua/stemmer'


group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'binding_of_caller'
end
group :development do
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'faker'
end
group :test do
  gem 'capybara', '>= 2.15'
  gem 'selenium-webdriver'
  gem 'chromedriver-helper'
end

gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
gem 'haml-rails'
gem 'high_voltage'
gem 'pg'
gem 'mini_racer', :platform=>:ruby
gem 'dotenv-rails'

group :development, :test do
  gem 'better_errors'
  gem 'better_errors-pry'
  gem 'html2haml'
  gem 'rails_layout'

  # Testing
  gem 'rspec-rails'
  gem 'factory_bot_rails'
end

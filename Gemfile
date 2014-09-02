source 'https://rubygems.org'

ruby '2.1.2'

gem 'rails', '3.2.13'

gem "puma"
gem 'sidekiq'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'pg'
gem 'rest-client'

# gem 'thin'

gem 'nokogiri'
gem 'dalli'
gem 'memcachier'
gem 'rack-contrib'
gem 'soulmate', :require => 'soulmate/server'
gem 'sinatra', require: false
gem 'slim'
gem 'pusher'

gem "typhoeus"
gem 'faraday'
gem 'faraday_middleware'

gem 'simple_form'
gem 'log4r'
# gem 'bson_ext'
# gem 'mongo'
gem "mongoid"

gem "jbuilder"
gem 'money'
gem 'kaminari' #for pagination
gem 'activerecord-import', '~> 0.3.1'
gem 'geokit-rails'
gem 'geoip'
gem 'geo-distance'
gem 'geocoder' # for postcode lookup
gem 'rubyzip', require: false

gem 'figaro'
gem 'savon', '~> 2.3.0' # used for SOAP messaging
gem 'zipruby', require: false

gem 'newrelic_rpm'
gem "oink" #Rails AR profiler
gem 'jquery-rails-cdn'

# gem "resque", "~> 2.0.0.pre.1", github: "resque/resque"
gem 'smarter_csv', require: false
gem 'carrierwave'
gem "fog"

gem 'ruby-prof', require: false
gem 'meta-tags', :require => 'meta_tags'
gem  'certified'
gem 'hirefire-resource'
#gem 'bugsnag'
gem 'keen'
gem 'useragent'
gem 'rack-cors'

gem 'descriptive-statistics'
gem "asset_sync"

#gem 'iso_country_codes'
# Gems used only for assets and not required
# in production environments by default.
group :assets do

 
  # gem 'therubyracer', '~> 0.10.2'
  #gem "less-rails" #Sprockets (what Rails 3.1 uses for its asset pipeline) supports LESS
  gem "twitter-bootstrap-rails"

  # gem 'jquery-ui-rails'
  gem 'jquery-rails'
  # gem 'sass-rails',   '~> 3.2.3'
  # gem 'coffee-rails', '~> 3.2.1'

  # gem 'zepto-rails', :github => 'frontfoot/zepto-rails'
  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  gem 'therubyracer', :platforms => :ruby
  gem 'libv8', '~> 3.11.8'  # Update version number as needed

  gem 'uglifier', '>= 1.0.3'
  # gem 'compass-rails' # you need this or you get an err
  # gem 'zurb-foundation', '~> 4.0.0'
  # gem 'masonry-rails'
  gem 'angularjs-rails'
  gem 'underscore-rails'
  gem 'accountingjs-rails'
  gem 'angular-ui-bootstrap-rails'
  gem 'turbo-sprockets-rails3'
end

group :development do
  gem "awesome_print"
  # gem 'better_errors'
  # gem "binding_of_caller"
end

group :test do
  gem 'vcr'
  gem 'webmock'
end



gem 'rails_12factor', group: :production

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'debugger'

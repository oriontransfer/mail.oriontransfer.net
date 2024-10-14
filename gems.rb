# frozen_string_literal: true

source 'https://rubygems.org'

group :preload do
	gem 'utopia', '~> 2.17'
	# gem 'utopia-gallery'
	# gem 'utopia-analytics'
	
	gem 'variant'
	
	gem "db"
	gem "db-mariadb"
	gem "db-model"
	gem "db-migrate-x"
	
	gem "migrate"
	gem "latinum", "~> 1.0"
	gem "mapping", "~> 1.0"
	gem "thread-local"
	
	gem "xrb-formatters"
end

gem 'bake'
gem 'bundler'
gem 'rack-test'
gem "async-http"

group :test do
	gem "sus"
	gem 'covered'
	
	gem "sus-fixtures-async-http"
	gem "sus-fixtures-async-webdriver"
	
	gem 'benchmark-http'
end

group :production do
	gem 'falcon'
end

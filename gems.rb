# frozen_string_literal: true

source 'https://rubygems.org'

group :preload do
	gem 'utopia', '~> 2.17'
	# gem 'utopia-gallery'
	# gem 'utopia-analytics'
	
	gem 'variant'
	
	gem "db"
	gem "db-mariadb"
	gem "db-model", git: "https://github.com/socketry/db-model"
	gem "db-migrate", git: "https://github.com/socketry/db-migrate"
	
	gem "migrate"
	gem "latinum", "~> 1.0"
	gem "mapping", "~> 1.0"
	
	gem "trenni-formatters", "~> 2.0"
end

gem 'bake'
gem 'bundler'
gem 'rack-test'

group :test do
	gem "sus"
	gem 'covered'
	
	gem "sus-fixtures-async-http"
	gem "sus-fixtures-async-webdriver", "~> 0.2"
	
	# Fixed in latest selenium <https://github.com/SeleniumHQ/selenium/pull/9007>:
	gem 'rexml'
	
	gem 'benchmark-http'
end

group :production do
	gem 'falcon'
end

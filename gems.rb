# frozen_string_literal: true

source 'https://rubygems.org'

group :preload do
	gem 'utopia', '~> 2.17.0'
	# gem 'utopia-gallery'
	# gem 'utopia-analytics'
	
	gem 'variant'
	
	gem "activerecord"
	gem "activerecord-migrations"
	gem "activerecord-configurations"
	gem "activerecord-rack"
	
	gem "mysql2"
	gem "latinum", "~> 1.0"
	gem "mapping", "~> 1.0"
	
	gem "trenni-formatters", "~> 2.0"
end

gem 'rake'
gem 'bake'
gem 'bundler'
gem 'rack-test'

group :development do
	gem 'guard-falcon', require: false
	gem 'guard-rspec', require: false
	
	gem 'rspec'
	gem 'covered'
	
	gem 'async-rspec'
	gem 'benchmark-http'
end

group :production do
	gem 'falcon'
end

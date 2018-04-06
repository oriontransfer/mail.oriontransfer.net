
source "https://rubygems.org"

gem "utopia", "~> 2.3.0"
# gem "utopia-gallery"
# gem "utopia-analytics"

gem "rake"
gem "bundler"

gem "activerecord", "~> 5.0"
gem "activerecord-migrations"
gem "activerecord-configurations"
gem "activerecord-rack"

gem "mysql2"

gem "rainbow", "~> 2.1"

gem "trenni-formatters", "~> 2.0"
gem "latinum", "~> 1.0"
gem "mapping", "~> 1.0"

gem "rack-freeze", "~> 1.2"

group :development do
	# For `rake server`:
	gem "guard-falcon", require: false
	gem 'guard-rspec', require: false
	
	# For `rake console`:
	gem "pry"
	gem "rack-test"
	
	# For `rspec` testing:
	gem "rspec"
	gem "simplecov"
end

group :production do
	# Used for passenger-config to restart server after deployment:
	gem "passenger"
end

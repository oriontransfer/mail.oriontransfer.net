
source "https://rubygems.org"

gem "utopia", "~> 1.8.3"
# gem "utopia-tags-gallery"
# gem "utopia-tags-google-analytics"

gem "activerecord", "~> 5.0"
gem "activerecord-migrations"
gem "activerecord-rack"

gem "mysql2"

gem "rainbow", "~> 2.0.0"

gem "rake"
gem "bundler"

gem "trenni-formatters", "~> 1.2"
gem "latinum", "~> 1.0"
gem "mapping", "~> 1.0"

group :development do
	# For `rake server`:
	gem "puma"
	
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

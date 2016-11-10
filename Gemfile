
source "https://rubygems.org"

gem "utopia", "~> 1.8.3"
# gem "utopia-tags-gallery"
# gem "utopia-tags-google-analytics"

gem "rake"
gem "bundler"

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

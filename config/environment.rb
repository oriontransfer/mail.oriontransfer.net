
require 'bundler/setup'
Bundler.setup

require 'utopia/setup'
Utopia.setup

RACK_ENV = ENV.fetch('RACK_ENV', :development).to_sym unless defined? RACK_ENV

require 'active_record'
require 'mysql2'

ActiveRecord::Base.configurations = {
	'production' => {
		adapter: "mysql2",
		database: "vmail",
		username: "vmail",
		password: "JALRtzMvm9b6DKwz",
		strict: true,
		host: '127.0.0.1',
		port: 60526
	}
}

DATABASE_ENV = (ENV['DATABASE_ENV'] || :production).to_sym

# Connect to database:
unless ActiveRecord::Base.connected?
	ActiveRecord::Base.establish_connection(DATABASE_ENV)
end

require 'model'
require 'formatters'

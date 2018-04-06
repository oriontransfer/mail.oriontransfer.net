
require 'bundler/setup'
Bundler.setup

require 'utopia/setup'
Utopia.setup

RACK_ENV = ENV.fetch('RACK_ENV', :development).to_sym unless defined? RACK_ENV

require 'active_record'
require 'mysql2'

require_relative '../db/environment'

# Connect to database:
ActiveRecord::Base.setup_connection(DATABASE_ENV)

require 'vmail/formatters'

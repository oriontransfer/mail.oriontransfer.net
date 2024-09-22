
require 'db/client'
require 'db/mariadb'
require 'thread/local'

module VMail
	case Variant.default
	when :production
		MAIL_ROOT = "/srv/mail"
		DOMAIN = 'https://mail.oriontransfer.net'
		CREDENTIALS = {username: 'http', database: 'vmail'}
	when :development
		MAIL_ROOT = "db/mail"
		DOMAIN = 'https://localhost'
		CREDENTIALS = {username: 'test', password: 'test', database: 'vmail_development'}
	when :testing
		MAIL_ROOT = "db/mail"
		DOMAIN = 'https://localhost'
		CREDENTIALS = {username: 'test', password: 'test', database: 'test', host: '127.0.0.1'}
	end
	
	module Database
		extend Thread::Local
		
		def self.local
			DB::Client.new(DB::MariaDB::Adapter.new(**CREDENTIALS))
		end
	end
end

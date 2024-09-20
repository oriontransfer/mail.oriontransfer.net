
require 'db/client'
require 'db/mariadb'
require 'thread/local'

module VMail
	module Database
		extend Thread::Local
		
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
			CREDENTIALS = {username: 'test', password: 'test', database: 'test', unix_socket: "/opt/local/var/run/mariadb-10.11/mysqld.sock"}
		end
		
		def self.local
			DB::Client.new(DB::MariaDB::Adapter.new(**CREDENTIALS))
		end
	end
end

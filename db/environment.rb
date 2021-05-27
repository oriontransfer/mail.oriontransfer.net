
require 'db/client'
require 'db/mariadb'

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
	
	DATABASE = DB::Client.new(DB::MariaDB::Adapter.new(**CREDENTIALS))
end


require 'active_record'
require 'mysql2'

require 'active_record/configurations'

class ActiveRecord::Base
	extend ActiveRecord::Configurations
	
	configure(:production) do
		prefix 'vmail'
		adapter 'mysql2'
		
		database 'vmail'
		username 'http'
		strict true
		mail_root '/srv/mail'
		
		domain 'https://mail.oriontransfer.net'
	end

	configure(:development, parent: :production) do
		database 'vmail_development'
		mail_root 'db/mail'
	end
	
	configure(:test, parent: :production) do
		database 'vmail_test'
		
		domain nil
	end
end

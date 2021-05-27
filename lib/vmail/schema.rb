require 'async'
require 'db/model/schema'

require_relative 'account'
require_relative 'domain'
require_relative 'password_reset'

module VMail
	class Schema
		include DB::Model::Schema
		
		def accounts
			table(Account)
		end
		
		def domains
			table(Domain)
		end
		
		def password_resets
			table(PasswordReset)
		end
	end
	
	def self.transaction(&block)
		DATABASE.transaction(&block)
	end
	
	def self.schema
		DATABASE.transaction do |session|
			yield Schema.new(session)
		end
	end
end

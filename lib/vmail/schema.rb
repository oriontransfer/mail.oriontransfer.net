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
		
		def clear!
			accounts.delete
			domains.delete
			password_resets.delete
		end
		
		# It might make more sense to write `accounts.for_email_address`.
		def account_for_email_address(email_address)
			local_part, domain_name = email_address.split("@")
			
			domain = domains.where(name: domain_name).first
			
			if domain
				return domain.accounts.where(local_part: local_part).first
			else
				return nil
			end
		end
	end
	
	def self.transaction(&block)
		Sync do
			DATABASE.transaction(&block)
		end
	end
	
	def self.schema
		Sync do
			DATABASE.transaction do |session|
				yield Schema.new(session)
			end
		end
	end
end

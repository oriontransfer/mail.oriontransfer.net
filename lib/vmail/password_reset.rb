
require_relative 'domain'

require 'xrb/uri'

module VMail
	module TimestampWithoutTimeZone
		def self.load(value)
			DateTime.parse(value)
		end
		
		def self.dump(value)
		end
	end
	
	class PasswordReset
		include DB::Model::Record
		@type = :password_resets
		
		property :id
		property :account_id
		property :token
		property :used_at
		property :created_at
		property :updated_at
		
		def account
			scope(Account, id: self.account_id)
		end
		
		def generate_token
			self.token ||= SecureRandom.hex(16)
		end
		
		def flatten!
			self.created_at ||= Time.now
			self.generate_token
			
			if @changed.any?
				self.updated_at = Time.now
			end
			
			super
		end
		
		def url(domain = DOMAIN)
			XRB::URI("#{domain}/password-reset/index", id: self.id, token: self.token)
		end
		
		EXPIRES_AFTER = (60 * 60 * 24 * 2)
		
		def expired?
			self.used_at != nil or self.created_at < (Time.now - EXPIRES_AFTER)
		end
	end
end

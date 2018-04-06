
require_relative 'domain'

require 'trenni/uri'

module VMail
	class PasswordReset < ActiveRecord::Base
		before_save def generate_tokens
			self.token ||= SecureRandom.hex(16)
			
			return true
		end
		
		def url(domain = default_domain)
			Trenni::URI("#{domain}/password-reset/index", id: self.id, token: self.token)
		end
		
		def expired?
			self.used_at != nil or self.created_at < 2.days.ago
		end
		
		belongs_to :account
		
		private
		
		def default_domain
			self.class.connection_config[:domain]
		end
	end
end

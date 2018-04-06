
module VMail
	class PasswordReset
		before_save def generate_tokens
			self.token ||= SecureRandom.hex(16)
			
			return true
		end
		
		belongs_to :account
	end
end

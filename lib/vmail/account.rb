
require_relative 'domain'

require 'db/model/record'

require 'securerandom'
require 'digest/sha1'
require 'base64'

module VMail
	class Account
		include DB::Model::Record
		@type = :accounts
		
		property :id
		
		property :local_part
		property :domain_id
		
		property :forward
		property :name
		property :password
		property :mail_location
		
		property :is_enabled
		property :is_admin
		
		property :created_at
		property :updated_at
		
		def domain
			scope(Domain, id: self.domain_id)
		end
		
		def password_resets
			scope(PasswordReset, account_id: self.id)
		end
		
		attr :password_plaintext
		
		def password_plaintext=(plaintext)
			if plaintext
				self.password = encode_password(plaintext)
			end
			
			@password_plaintext = plaintext
		end
		
		def home_path
			if domain = self.domain.first
				File.join(MAIL_ROOT, domain.name, local_part)
			end
		end
		
		def disk_usage_string
			`sudo -n du -hs #{home_path.dump}`.split(/\s+/).first
		end
		
		def email_address
			if domain = self.domain.first
				return "#{local_part}@#{domain.name}"
			end
		end
		
		def description
			if self.forward
				"#{self.email_address} ➠ #{self.forward}"
			else
				self.email_address
			end
		end
		
		def plaintext_authenticate(password)
			check_password(password, self.password)
		end
		
		PASSWORD_CHARACTERS = [*('a'..'z'), *('A'..'Z'),*('2'..'9'),'@', '$', '%', '&', '*', ':'].flatten - ['i', 'l', 'I', 'L', 'j', 'J']
		
		def self.generate_password
			(0..12).map {PASSWORD_CHARACTERS.sample}.join
		end
		
		def flatten!
			self.created_at ||= Time.now
			
			if @changed.any?
				self.updated_at = Time.now
			end
			
			super
		end
		
		private
		
		# Generate 16 hex characters of random
		def generate_salt
			SecureRandom.hex(16)
		end
		
		# Hash the password using the given salt. If no salt is supplied, use a new
		# one.
		def encode_password(plaintext, salt=generate_salt)
			raise ArgumentError.new("Password must not be nil") if plaintext.nil?
			raise ArgumentError.new("Password must be at least 4 characters") if plaintext.size < 4
			raise ArgumentError.new("Salt must not be nil") if salt.nil?
			raise ArgumentError.new("Salt must be at least 8 characters") if salt.size < 8
			
			ssha = Digest::SHA1.digest(plaintext+salt) + salt
			
			return "{SSHA}" + Base64.strict_encode64(ssha).chomp
		end
		
		# Check the supplied password against the given hash and return true if they
		# match, else false.
		def check_password(password, ssha)
			decoded = Base64.decode64(ssha.sub(/^{SSHA}/, ''))
			
			raise ArgumentError.new("ssha is not valid") unless decoded.size >= 20+8
			
			hash = decoded[0...20] # isolate the hash
			salt = decoded[20..-1] # isolate the salt
			
			return encode_password(password, salt) == ssha
		end
	end
end

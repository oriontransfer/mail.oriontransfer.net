
require_relative 'domain'

require 'securerandom'
require 'digest/sha1'
require 'base64'

module VMail
	class Account < ActiveRecord::Base
		belongs_to :domain
		
		has_many :password_resets
		
		attr :password_plaintext
		
		def password_plaintext=(plaintext)
			if plaintext
				self.password = encode_password(plaintext)
			end
			
			@password_plaintext = plaintext
		end
		
		def self.mail_root
			@mail_root ||= self.connection_config[:mail_root]
		end
		
		def home_path
			File.join(self.class.mail_root, domain.name, local_part)
		end

		def disk_usage_string
			`sudo -n du -hs #{home_path.dump}`.split(/\s+/).first
		end

		def email_address
			return "#{local_part}@#{domain.name}"
		end
		
		def description
			if self.forward
				"#{self.email_address} ➠ #{self.forward}"
			else
				self.email_address
			end
		end
		
		def self.for_email_address(email_address)
			local_part, domain_name = email_address.split("@")
			
			domain = Domain.where(name: domain_name).first
			
			if domain
				return domain.accounts.where(local_part: local_part).first
			else
				return nil
			end
		end
		
		def plaintext_authenticate(password)
			check_password(password, self.password)
		end
		
		PASSWORD_CHARACTERS = [*('a'..'z'), *('A'..'Z'),*('2'..'9'),'@', '$', '%', '&', '*', ':'].flatten - ['i', 'l', 'I', 'L', 'j', 'J']
		
		def self.generate_password
			(0..12).map {PASSWORD_CHARACTERS.sample}.join
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

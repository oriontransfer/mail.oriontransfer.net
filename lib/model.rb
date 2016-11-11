
PASSWORD_CHARACTERS = [*('a'..'z'), *('A'..'Z'),*('2'..'9'),'@', '$', '%', '&', '*', ':'].flatten - ['i', 'l', 'I', 'L', 'j', 'J']

def generate_password
	(0..12).map {PASSWORD_CHARACTERS.sample}.join
end

require 'securerandom'
require 'digest/sha1'
require 'base64'

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

class Account < ActiveRecord::Base
	belongs_to :domain
	
	attr :password_plaintext
	
	def password_plaintext=(plaintext)
		if plaintext
			self.password = encode_password(plaintext)
		end
		
		@password_plaintext = plaintext
	end
	
	def home_path
		return "/srv/mail/#{domain.name}/#{local_part}/"
	end

	def disk_usage_string
		`sudo du -hs #{home_path.dump}`.split(/\s+/).first
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
end

class Domain < ActiveRecord::Base
	has_many :accounts, :dependent => :destroy
	
	def create_postmaster_account(password = nil)
		postmaster = accounts.where(local_part: "postmaster").first
	
		if postmaster == nil
			postmaster = self.class.setup_mail_account("Postmaster", "postmaster", name, password)
		end
	
		return postmaster
	end
	
	def home_path
		"/srv/mail/#{name}"
	end

	def disk_usage_string
		`sudo du -hs #{home_path.dump}`.split(/\s+/).first
	end
	
	def self.setup_mail_account(full_name, local_part, domain_name, password)
		domain = Domain.find_or_create_by(name: domain_name)
		account = domain.accounts.where(local_part: local_part).first

		if account == nil
			account = domain.accounts.build(local_part: local_part)
		end

		account.name = full_name
		account.password_plaintext = password
		account.save

		return account
	end
	
	def self.ensure_postmasters_exist
		Domains.find_each {|d| d.create_postmaster_account}
	end
end

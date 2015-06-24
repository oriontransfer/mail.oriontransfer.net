
PASSWORD_CHARACTERS = [*('a'..'z'), *('A'..'Z'),*('2'..'9'),'@', '$', '%', '&', '*', ':'].flatten - ['i', 'l', 'I', 'L', 'j', 'J']

def generate_password
	(0..8).map {PASSWORD_CHARACTERS.sample}.join
end

require 'activerecord'

ActiveRecord::Base.configurations = {
	production: {
		adapter: "mysql2",
		database: "vmail",
		username: "vmail",
		password: "JALRtzMvm9b6DKwz",
		strict: true,
	}
}

DATABASE_ENV = (ENV['DATABASE_ENV'] || :production).to_sym

# Connect to database:
unless ActiveRecord::Base.connected?
	ActiveRecord::Base.establish_connection(DATABASE_ENV)
end

require 'digest/sha1'
require 'base64'

def encode_password(plaintext)
	salt = (0...12).collect{(rand*255).to_i.chr}.join
	ssha = Digest::SHA1.digest(plaintext+salt) + salt

	return "{SSHA}" + Base64.strict_encode64(ssha).chomp
end

class Account < ActiveRecord::Base
	belongs_to :domain
	
	def password=(plaintext)
		self[:password] = encode_password(plaintext)
	end
	
	def home_path
		return "/srv/mail/#{domain.name}/#{local_part}/"
	end

	def disk_usage
		if File.exist? home_path
			`sudo du -hs #{home_path.dump}`.split(/\s+/).first
		end
	end

	def email_address
		return "#{local_part}@#{domain.name}"
	end
	
	def self.for_email_address(email_address)
		local_part, domain_name = email_address.split("@")
		
		domain = Domain.first(name: domain_name)
		
		if domain
			return domain.accounts.first(local_part: local_part)
		else
			return nil
		end
	end
end

class Domain < ActiveRecord::Base
	has_many :accounts
	
	def create_postmaster_account(password = nil)
		postmaster = accounts.first(local_part: "postmaster")
	
		if postmaster == nil
			postmaster = self.class.setup_mail_account("Postmaster", "postmaster", name, password)
		end
	
		return postmaster
	end
	
	def home_path
		"/srv/mail/#{name}"
	end

	def disk_usage
		if File.exist? home_path
			`sudo du -hs #{home_path.dump}`.split(/\s+/).first
		end
	end
	
	def self.setup_mail_account(full_name, local_part, domain_name, password)
		domain = Domain.find_or_create_by(name: domain_name)
		account = domain.accounts.first(local_part: local_part)

		if account == nil
			account = domain.accounts.build(local_part: local_part)
		end

		account.name = full_name
		account.password = password
		account.save

		return account
	end
	
	def self.ensure_postmasters_exist
		Domains.find_each {|d| d.create_postmaster_account}
	end
end
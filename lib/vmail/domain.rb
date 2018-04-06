
require 'active_record'

module VMail
	class Domain < ActiveRecord::Base
		has_many :accounts, :dependent => :destroy
		
		def create_postmaster_account(password = nil)
			postmaster = accounts.where(local_part: "postmaster").first
		
			if postmaster == nil
				postmaster = self.class.setup_mail_account("Postmaster", "postmaster", name, password)
			end
		
			return postmaster
		end
		
		def self.mail_root
			@mail_root ||= self.connection_config[:mail_root]
		end
		
		def home_path
			File.join(self.class.mail_root, name)
		end

		def disk_usage_string
			`sudo -n du -hs #{home_path.dump}`.split(/\s+/).first
		end
		
		def self.setup_mail_account(full_name, local_part, domain_name, password)
			domain = self.find_or_create_by(name: domain_name)
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
			self.find_each {|d| d.create_postmaster_account}
		end
	end
end

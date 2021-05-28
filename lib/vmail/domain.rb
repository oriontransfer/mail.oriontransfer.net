
require 'db/model/record'

module VMail
	class Domain
		include DB::Model::Record
		@type = :domains
		
		property :id
		property :name
		property :is_enabled
		property :created_at
		property :updated_at
		
		def accounts
			scope(Account, domain_id: self.id)
		end
		
		def flatten!
			self.created_at ||= Time.now
			
			if @changed.any?
				self.updated_at = Time.now
			end
			
			super
		end
		
		def create_postmaster_account(password = nil)
			postmaster = accounts.where(local_part: "postmaster").first
			
			if postmaster == nil
				postmaster = self.class.setup_mail_account("Postmaster", "postmaster", name, password)
			end
			
			return postmaster
		end
		
		def home_path
			File.join(MAIL_ROOT, name)
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

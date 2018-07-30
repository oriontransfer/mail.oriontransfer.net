
namespace :mail do
	task :summary => :environment do
		require 'rainbow'
		
		VMail::Domain.find_each do |domain|
			domain_color = domain.is_enabled ? :green : :red
			
			puts "[#{domain.id}] #{Rainbow(domain.name).foreground(domain_color)} (#{domain.accounts.count} accounts): #{domain.disk_usage_string}"
			
			domain.accounts.each do |account|
				account_color = account.is_enabled ? :green : :red
				account_color = :blue if account.forward
				
				puts "[#{account.id}] \t#{Rainbow(account.description).foreground(account_color)}: #{account.disk_usage_string}"
			end
		end
	end
end

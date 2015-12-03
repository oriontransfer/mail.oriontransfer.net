
task :server do
	system('puma')
end

task :deploy do
	# This task is typiclly run after the site is updated but before the server is restarted.
	puts "Preparing to deploy site in #{Dir.pwd.inspect}..."
end

task :environment do
	require_relative 'lib/mail/model'
end

task :summary => :environment do
	Domain.find_each do |domain|
		domain_color = domain.is_enabled ? :green : :red
		
		puts "#{Rainbow(domain.name).foreground(domain_color)} (#{domain.accounts.count} accounts)"
		
		domain.accounts.each do |account|
			account_color = account.is_enabled ? :green : :red
			account_color = :blue if account.forward
			
			puts "\t#{Rainbow(account.email_address).foreground(account_color)}: #{account.disk_usage}"
		end
	end
end

task :console => :environment  do
	require 'pry'
	
	binding.pry
end

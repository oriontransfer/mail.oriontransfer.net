
task :server do
	system('puma')
end

task :deploy do
	# This task is typiclly run after the site is updated but before the server is restarted.
	puts "Preparing to deploy site in #{Dir.pwd.inspect}..."
end

task :summary do
	Domain.each do |domain|
		domain_color = domain.is_active ? :green : :red
		
		puts "#{Rainbow(domain.name).foreground(domain_color)} (#{domain.accounts.count} accounts)"
		
		domain.accounts.each do |account|
			account_color = account.is_active ? :green : :red
			account_color = :blue if account.forward
			
			puts "\t#{Rainbow(account.email_address).foreground(account_color)}: #{account.disk_usage}"
		end
	end
end

task :console do
	require 'pry'
	require_relative 'lib/mail/model'
	
	binding.pry
end


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
	require 'rainbow'
	
	Domain.find_each do |domain|
		domain_color = domain.is_enabled ? :green : :red
		
		puts "[#{domain.id}] #{Rainbow(domain.name).foreground(domain_color)} (#{domain.accounts.count} accounts)"
		
		domain.accounts.each do |account|
			account_color = account.is_enabled ? :green : :red
			account_color = :blue if account.forward
			
			puts "[#{account.id}] \t#{Rainbow(account.description).foreground(account_color)}: #{account.disk_usage}"
		end
	end
end

task :console => :environment  do
	require 'pry'
	
	binding.pry
end


task :server do
	system('puma')
end

task :deploy do
	# This task is typiclly run after the site is updated but before the server is restarted.
	puts "Preparing to deploy site in #{Dir.pwd.inspect}..."
end

task :console do
	require 'pry'
	require_relative 'lib/mail/model'
	
	binding.pry
end

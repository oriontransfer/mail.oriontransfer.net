# frozen_string_literal: true

# Prepare the application for start/restart.
def deploy
	# This task is typiclly run after the site is updated but before the server is restarted.
	call 'migrate'
end

# Restart the application server.
def restart
	call 'falcon:supervisor:restart'
end

# Start the development server.
def default
	call 'utopia:development'
end

def environment
	require_relative 'config/environment'
end

def shell
	environment
	
	VMail.schema do |schema|
		binding.irb
	end
end

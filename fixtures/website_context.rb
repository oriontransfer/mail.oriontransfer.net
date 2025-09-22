# frozen_string_literal: true

require 'rack/test'
require 'protocol/rack/adapter'
require 'protocol/http/reference'

require 'sus/fixtures/async/http/server_context'
require 'sus/fixtures/async/webdriver/session_context'

require 'falcon/middleware/verbose'

module WebsiteContext
	include Sus::Fixtures::Async::HTTP::ServerContext
	include Sus::Fixtures::Async::WebDriver::SessionContext
	
	def app
		Rack::Builder.parse_file(
			File.expand_path('../config.ru', __dir__)
		)
	end
	
	def middleware
		middleware = Protocol::Rack::Adapter.new(app)
		
		# Verbose request logging:
		# middleware = Falcon::Middleware::Verbose.new(middleware)
		
		middleware
	end
end

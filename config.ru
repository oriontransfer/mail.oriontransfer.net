#!/usr/bin/env rackup

require_relative 'config/environment'

require 'active_record/rack'
require 'rack/freeze'

if RACK_ENV == :production
	# Handle exceptions in production with a error page and send an email notification:
	use Utopia::Exceptions::Handler
	use Utopia::Exceptions::Mailer
else
	# We want to propate exceptions up when running tests:
	use Rack::ShowExceptions unless RACK_ENV == :test
	
	# Serve the public directory in a similar way to the web server:
	use Utopia::Static, root: 'public'
end

use Rack::Sendfile

use Utopia::ContentLength

use Utopia::Redirection::Rewrite,
	'/' => '/restricted-area'

use Utopia::Redirection::DirectoryIndex

use Utopia::Redirection::Errors,
	404 => '/errors/file-not-found'

require 'utopia/session'
use Utopia::Session,
	:expires_after => 3600 * 24,
	:secret => ENV['UTOPIA_SESSION_SECRET']

unless RACK_ENV == :test
	use ActiveRecord::Rack::ConnectionManagement
end

use Utopia::Controller

use Utopia::Static

# Serve dynamic content
use Utopia::Content

run lambda { |env| [404, {}, []] }

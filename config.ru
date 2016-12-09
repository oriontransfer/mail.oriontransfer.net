#!/usr/bin/env rackup

require_relative 'config/environment'

require 'utopia/session'
require 'active_record/rack'

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

use Utopia::Session,
	:expires_after => 3600 * 24,
	:secret => ENV['UTOPIA_SESSION_SECRET']

unless RACK_ENV == :test
	use ActiveRecord::Rack::ConnectionManagement
end

use Utopia::Controller,
	cache_controllers: (RACK_ENV == :production),
	base: Utopia::Controller::Base

use Utopia::Static

# Serve dynamic content
use Utopia::Content,
	cache_templates: (RACK_ENV == :production),
	tags: {
		'deferred' => Utopia::Tags::Deferred,
		'override' => Utopia::Tags::Override,
		'node' => Utopia::Tags::Node,
		'environment' => Utopia::Tags::Environment.for(RACK_ENV)
	}

run lambda { |env| [404, {}, []] }

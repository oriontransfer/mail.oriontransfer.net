# frozen_string_literal: true

require 'rack/test'
require 'async/rspec/reactor'

RSpec.shared_context "website" do
	include_context Async::RSpec::Reactor
	include Rack::Test::Methods
	
	let(:app) do
		Rack::Builder.parse_file(
			File.expand_path('../config.ru', __dir__)
		).first
	end
	
	before(:all) do
		require 'falcon/server'
		require 'falcon/endpoint'
		require 'async/io/shared_endpoint'
	end
	
	let(:endpoint) {Falcon::Endpoint.parse("https://localhost:9294")}
	
	before do
		@bound_endpoint = Async::IO::SharedEndpoint.bound(endpoint, close_on_exec: true)
		
		@server_task = reactor.async do
			middleware = Falcon::Server.middleware(app)
			
			server = Falcon::Server.new(middleware, @bound_endpoint, protocol: endpoint.protocol, scheme: endpoint.scheme)
			
			server.run
		end
	end
	
	after do
		@server_task.stop
		@bound_endpoint.close
	end
end

RSpec.shared_context "browser" do
	include_context "website"
	
	before(:all) do
		require 'webdrivers'
		require 'selenium/webdriver'
	end
	
	before do
		options = Selenium::WebDriver::Chrome::Options.new
		options.add_argument('--allow-insecure-localhost')
		options.add_argument('--headless')
		options.add_argument('--disable-gpu')
		
		@driver = Selenium::WebDriver.for(:chrome, options: options)
	end
	
	after do
		@driver&.quit
	end
	
	def visit(path)
		uri = URI(endpoint.url) + path
		@driver.navigate.to(uri)
	end
	
	def find_form(**options)
		if options.empty?
			options = {tag_name: "form"}
		end
		
		return @driver.find_element(**options)
	end
	
	def body
		@driver.find_element(tag_name: "body")
	end
end

RSpec.shared_examples_for "valid page" do |path|
	include_context "website"
	
	it "can access #{path}" do
		get path
		
		while last_response.redirect?
			follow_redirect!
		end
		
		expect(last_response.status).to be == 200
	end
end

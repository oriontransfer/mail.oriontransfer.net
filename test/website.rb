# frozen_string_literal: true

require 'website_context'
require 'benchmark/http/spider'

describe "website" do
	include WebsiteContext
	
	let(:spider) {Benchmark::HTTP::Spider.new(depth: 128)}
	let(:statistics) {Benchmark::HTTP::Statistics.new}
	
	it "should be responsive" do
		spider.fetch(statistics, client, endpoint.url) do |method, uri, response|
			if response.failure?
				Console.error(self) {"#{method} #{uri} -> #{response.status}"}
			end
		end.wait
		
		inform(statistics.print)
		
		expect(statistics.samples).to be(:any?)
		expect(statistics.failed).to be(:zero?)
	end
end

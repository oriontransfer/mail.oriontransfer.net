
require 'website_context'

describe "pages/login" do
	include WebsiteContext
	
	let(:password) {"secure123"}
	
	before do
		VMail.schema do |schema|
			schema.clear!
			
			@domain = schema.domains.create(name: 'localhost')
			
			@account = @domain.accounts.new(local_part: 'test', name: 'Test', is_enabled: true, is_admin: true)
			@account.password_plaintext = password
			@account.save
		end
	end
	
	it "can log in" do
		navigate_to "/login"
		
		session.fill_in "email", @account.email_address
		session.fill_in "password", password
		
		session.click_button "Login"
	rescue => error
		pp error: error.inspect
	end
end

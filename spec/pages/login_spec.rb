
require_relative '../website_context'

RSpec.describe "pages/login", timeout: false do
	include_context "browser"
	
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
		visit "/login"
		
		form = find_form
		form.find_element(name: 'email').send_keys(@account.email_address)
		form.find_element(name: 'password').send_keys(password)
		form.submit
		
		expect(body.text).to include('Accounts')
		expect(body.text).to include('test@localhost')
	end
end

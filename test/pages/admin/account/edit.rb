
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
			@account.totp_secret = "JBSWY3DPEHPK3PXP"  # Fixed secret for testing
			@account.totp_enabled = true
			@account.save
		end
	end
	
	it "can log in" do
		navigate_to "/login"
		
		session.fill_in "email", @account.email_address
		session.fill_in "password", password
		
		# Generate a valid TOTP token for the test:
		totp = ROTP::TOTP.new(@account.totp_secret)
		current_token = totp.now
		session.fill_in "totp_token", current_token
		
		session.click_button "Login"
		
		# This prevents a race condition between the `click_button` and the `navigate_to` operations:
		expect(session).to have_element(xpath: "//h1[text()='Accounts']")
		
		navigate_to "/admin/accounts/edit?id=#{@account.id}"
		
		expect(session).to have_element(xpath: "//input[@name='local_part' and @value='test']")
		find_element(xpath: "//input[@name='local_part' and @value='test']")
	end
end

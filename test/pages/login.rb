
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
	
	it "redirects to TOTP setup when TOTP is not configured" do
		navigate_to "/login"
		
		session.fill_in "email", @account.email_address
		session.fill_in "password", password
		
		session.click_button "Login"
		
		# Should redirect to TOTP setup page
		expect(session.current_url).to be(:include?, "/totp-setup")
	end
	
	it "can complete TOTP setup and login" do
		navigate_to "/login"
		
		session.fill_in "email", @account.email_address
		session.fill_in "password", password
		
		session.click_button "Login"
		
		# Should be on TOTP setup page
		expect(session.current_url).to be(:include?, "/totp-setup")
		
		# Wait for the page to load and secret to be generated
		expect(session).to have_element(xpath: "//input[@name='totp_token']")
		
		# Reload account to get the generated secret
		VMail.schema do |schema|
			@account = schema.accounts.find(@account.id)
			
			# The controller should have already generated the secret
			expect(@account.totp_secret).not.to be_nil
			
			# Generate a valid TOTP token
			totp_token = @account.totp.now
			
			session.fill_in "totp_token", totp_token
			session.click_button "Complete Setup"
			
			# Should redirect to admin dashboard - look for admin page elements
			expect(session).to have_element(xpath: "//table[@class='listing']//td[text()='test@localhost']")
		end
	end
	
	it "can login with TOTP when already configured" do
		# Setup TOTP for the account first
		VMail.schema do |schema|
			@account.generate_totp_secret!
			@account.totp_enabled = true
			@account.save
		end
		
		navigate_to "/login"
		
		# Fill in all fields at once
		session.fill_in "email", @account.email_address
		session.fill_in "password", password
		
		VMail.schema do |schema|
			@account = schema.accounts.find(@account.id)
			totp_token = @account.totp.now
			
			session.fill_in "totp_token", totp_token
			session.click_button "Login"
			
			# Should redirect to admin dashboard
			expect(session).to have_element(xpath: "//table[@class='listing']//td[text()='test@localhost']")
		end
	end
	
	it "shows error for missing TOTP when required" do
		# Setup TOTP for the account first
		VMail.schema do |schema|
			@account.generate_totp_secret!
			@account.totp_enabled = true
			@account.save
		end
		
		navigate_to "/login"
		
		session.fill_in "email", @account.email_address
		session.fill_in "password", password
		# Don't fill in TOTP token
		
		session.click_button "Login"
		
		# Should stay on login page - look for login page elements with TOTP field required
		expect(session).to have_element(xpath: "//h1[text()='Login']")
		expect(session).to have_element(xpath: "//input[@name='totp_token'][@required]")
	end
end


require 'website_context'
require 'vmail'

RSpec.describe VMail::PasswordReset do
	include_context "website"
	
	let(:new_password) {"Hello World"}
	
	before do
		VMail.schema do |schema|
			schema.clear!
			
			@domain = schema.domains.create(name: 'localhost')
			@account = @domain.accounts.create(local_part: 'test', name: 'Test')
			@password_reset = @account.password_resets.create
		end
	end
	
	it "should be able to reset password" do
		expect(@password_reset.used_at).to be_nil
		expect(@password_reset.token).to_not be_nil
		
		get Trenni::URI("/password-reset/index", id: @password_reset.id, token: @password_reset.token)
		
		expect(last_response.status).to be == 200
		
		post Trenni::URI("/password-reset/index", id: @password_reset.id, token: @password_reset.token), {
			password_plaintext: new_password
		}
		
		VMail.transaction do |transaction|
			expect(@account.reload(transaction).plaintext_authenticate(new_password))
			expect(@password_reset.reload(transaction).used_at).to be_within(60).of(Time.now)
		end
	end
	
	it "should be fail to reset password if token is invalid" do
		get Trenni::URI("/password-reset/index", id: @password_reset.id, token: @password_reset.token + 'bad')
		
		expect(last_response.status).to be == 404
	end
end

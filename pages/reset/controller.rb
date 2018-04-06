
prepend Actions

AccountAttributes = Attributes.new(:name, :password_plaintext)

on 'index' do |request|
	fail! unless id = request.params['id']
	fail! unless token = request.params['token']
	fail! unless @password_reset = VMail::PasswordReset.where(id: id, token: token).first
	fail! if @password_reset.used_at?
	
	@account = @password_reset.account
	
	if request.post?
		attributes = AccountAttributes.select(request.params)
		
		@password_reset.transaction do
			@password_reset.used_at = Time.now
			@password_reset.save
			
			@account.update_attributes(attributes)
			@account.save
		end
		
		redirect! "success"
	end
end

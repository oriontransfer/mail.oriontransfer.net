
prepend Actions

AccountAttributes = VMail::Attributes.new(:name, :password_plaintext)

on 'index' do |request|
	fail! :not_found unless id = request.params['id']
	fail! :not_found unless token = request.params['token']
	fail! :not_found unless @password_reset = VMail::PasswordReset.where(id: id, token: token).first
	redirect! 'expired' if @password_reset.expired?
	
	@account = @password_reset.account
	
	if request.post?
		attributes = AccountAttributes.select(request.params)
		
		@password_reset.transaction do
			@password_reset.used_at = Time.now
			@password_reset.save
			
			@account.update_attributes(attributes)
			@account.save
		end
		
		redirect! 'success'
	end
end

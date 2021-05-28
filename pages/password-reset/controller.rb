
prepend Actions

AccountAttributes = VMail::Attributes.new(:name, :password_plaintext)

on 'index' do |request|
	fail! :not_found unless id = request.params['id']
	fail! :not_found unless token = request.params['token']
	
	VMail.schema do |schema|
		fail! :not_found unless @password_reset = schema.password_resets.where(id: id, token: token).first
		redirect! 'expired' if @password_reset.expired?
		
		@account = @password_reset.account.first
		
		if request.post?
			@password_reset.used_at = Time.now
			@password_reset.save
			
			AccountAttributes.assign(request.params, @account)
			@account.save
			
			redirect! 'success'
		end
	end
end

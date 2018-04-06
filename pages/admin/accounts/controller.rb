
prepend Actions

AccountAttributes = Attributes.new(
	:domain_id,
	:name, :local_part, :forward, :password_plaintext,
	:mail_location,
	:is_enabled, :is_admin
)

on 'new' do |request, path|
	@account = VMail::Account.new
	
	@account.password_plaintext = (0..8).map {PASSWORD_CHARACTERS.sample}.join
	
	if request.post?
		attributes = AccountAttributes.select(request.params)
		
		@account.update_attributes(attributes)
		
		@account.save
		
		redirect! "index"
	end
end

on 'edit' do |request, path|
	@account = VMail::Account.find(request[:id].to_i)
	
	if request.post?
		attributes = AccountAttributes.select(request.params)
		
		@account.update_attributes(attributes)
		
		@account.save
		
		redirect! request[:_return] || "index"
	end
end

on 'delete' do |request|
	fail!(:forbidden) unless request.post?
	
	if values = request.params['rows'].values
		ids = values.collect{|row| row['id']}
		
		VMail::Account.destroy(ids)
	end
	
	succeed!
end
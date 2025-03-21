
prepend Actions

AccountAttributes = VMail::Attributes.new(
	:domain_id,
	:name, :local_part, :forward, :password_plaintext,
	:mail_location,
	:is_enabled, :is_admin
)

on 'new' do |request, path|
	VMail.schema do |schema|
		@account = schema.accounts.new
		@account.password_plaintext = VMail::Account.generate_password
		
		if request.post?
			AccountAttributes.assign(request.params, @account)
			
			@account.save
			
			redirect! "index"
		end
	end
end

on 'edit' do |request, path|
	VMail.schema do |schema|
		@account = schema.accounts.find(request.params[:id].to_i)
		
		if request.post?
			AccountAttributes.assign(request.params, @account)
			
			@account.save
			
			redirect! request.params[:_return] || "index"
		end
	end
end

on 'delete' do |request|
	fail!(:forbidden) unless request.post?
	
	if values = request.params['rows'].values
		ids = values.collect{|row| row['id']}
		
		VMail.schema do |schema|
			schema.accounts.where(id: ids).delete
		end
	end
	
	succeed!
end

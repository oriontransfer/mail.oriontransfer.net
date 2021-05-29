
prepend Actions

PasswordResetAttributes = VMail::Attributes.new(
	:account_id
)

on 'new' do |request, path|
	VMail.schema do |schema|
		@password_reset = schema.password_resets.new
		
		if request.post?
			PasswordResetAttributes.assign(request.params, @password_reset)
			
			@password_reset.save
			
			redirect! "index"
		end
	end
end

on 'edit' do |request, path|
	VMail.schema do |schema|
		@password_reset = schema.password_resets.find(request[:id].to_i)
		
		if request.post?
			PasswordResetAttributes.assign(request.params, @password_reset)
			
			@password_reset.save
			
			redirect! request[:_return] || "index"
		end
	end
end

on 'delete' do |request|
	fail!(:forbidden) unless request.post?
	
	if values = request.params['rows'].values
		ids = values.collect{|row| row['id']}
		
		VMail::PasswordReset.destroy(ids)
	end
	
	succeed!
end

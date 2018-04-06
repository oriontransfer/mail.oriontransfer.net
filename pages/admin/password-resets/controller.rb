
prepend Actions

PasswordResetAttributes = VMail::Attributes.new(
	:account_id
)

on 'new' do |request, path|
	@password_reset = VMail::PasswordReset.new
	
	if request.post?
		attributes = PasswordResetAttributes.select(request.params)
		
		@password_reset.update_attributes(attributes)
		
		@password_reset.save
		
		redirect! "index"
	end
end

on 'edit' do |request, path|
	@password_reset = VMail::PasswordReset.find(request[:id].to_i)
	
	if request.post?
		attributes = PasswordResetAttributes.select(request.params)
		
		@password_reset.update_attributes(attributes)
		
		@password_reset.save
		
		redirect! request[:_return] || "index"
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

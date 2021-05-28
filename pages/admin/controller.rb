
prepend Actions

on '**' do |request|
	if account_id = request.session[:account_id]
		VMail.schema do |schema|
			@current_account = schema.accounts.find(account_id)
		end
	end
	
	fail! :unauthorized unless @current_account and @current_account.is_admin
end

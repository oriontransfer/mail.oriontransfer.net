
prepend Actions

on '**' do |request|
	if account_id = request.session[:account_id]
		@current_account = Account.find(account_id)
	end
	
	fail! :unauthorized unless @current_account and @current_account.is_admin
end

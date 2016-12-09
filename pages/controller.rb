
prepend Actions

on 'login' do |request|
	params = request.params
	
	if request.post?
		email, password = params.values_at('email', 'password')
		
		fail!(:unprocessible, "email and password are required") unless email and password
		
		account = Account.for_email_address(email)
		
		fail!(:unauthorized, "account does not have admin access") unless account&.is_admin
		
		if account&.plaintext_authenticate(password)
			request.session[:account_id] = account.id
			
			goto! "admin/accounts/index"
		else
			sleep 1
			
			fail! :unauthorized, "email or password is incorrect"
		end
	end
end

on :logout do |request|
	request.session[:account_id] = nil
	
	succeed!
end

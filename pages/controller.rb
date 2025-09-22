
prepend Actions

on 'login' do |request|
	params = request.params
	
	if request.post?
		email, password, totp_token = params.values_at('email', 'password', 'totp_token')
		
		fail!(:unprocessible, "email and password are required") unless email and password
		
		VMail.schema do |schema|
			account = schema.account_for_email_address(email)
			
			fail!(:unauthorized, "account does not have admin access") unless account&.is_admin
			
			if account&.plaintext_authenticate(password)
				# Check if TOTP setup is required
				if account.totp_setup_required?
					# Generate secret and redirect to setup page
					account.generate_totp_secret! unless account.totp_secret
					account.save
					request.session[:totp_setup_account_id] = account.id
					goto! "totp-setup"
				elsif account.totp_enabled
					# TOTP is enabled, require token
					if totp_token && !totp_token.empty?
						# Verify TOTP token
						if account.verify_totp(totp_token)
							request.session[:account_id] = account.id
							goto! "admin/accounts/index"
						else
							sleep 1
							fail! :unauthorized, "invalid TOTP token"
						end
					else
						# TOTP is required but no token provided, show TOTP input
						@totp_required = true
						@email = email
					end
				else
					# No TOTP required, login directly
					request.session[:account_id] = account.id
					goto! "admin/accounts/index"
				end
			else
				sleep 1
				fail! :unauthorized, "email (#{email}) or password (#{password}) is incorrect"
			end
		end
	end
end

on :logout do |request|
	request.session[:account_id] = nil
	
	succeed!
end

on 'totp-setup' do |request|
	params = request.params
	
	unless account_id = request.session[:totp_setup_account_id]
		goto! "login"
	end
	
	VMail.schema do |schema|
		@account = schema.accounts.find(account_id)
		
		fail!(:unauthorized, "account not found") unless @account
		
		if request.post?
			totp_token = params['totp_token']
			
			fail!(:unprocessible, "TOTP token is required") unless totp_token
			
			# Generate secret if not already present
			@account.generate_totp_secret! unless @account.totp_secret
			
			# Verify the entered token
			if @account.verify_totp(totp_token) || @account.totp.verify(totp_token, drift_behind: 15, drift_ahead: 15)
				@account.totp_enabled = true
				@account.save
				
				# Clear setup session and set normal session
				request.session[:totp_setup_account_id] = nil
				request.session[:account_id] = @account.id
				
				goto! "admin/accounts/index"
			else
				fail! :unauthorized, "invalid TOTP token"
			end
		else
			# Generate secret for first-time setup
			@account.generate_totp_secret! unless @account.totp_secret
			@account.save
		end
	end
end

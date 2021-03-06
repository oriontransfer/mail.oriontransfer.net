
require_relative '../lib/mail/domain'
require_relative '../lib/mail/account'

localhost = Domain.create(
	name: "localhost",
	is_enabled: true,
)

localhost.accounts.create(
	name: "Administrator",
	local_part: 'admin',
	is_enabled: true,
	is_admin: true,
	password_plaintext: 'admin'
)

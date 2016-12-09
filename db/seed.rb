
require_relative '../lib/model'

localhost = Domain.create(
	name: "localhost",
	is_enabled: true,
)

localhost.accounts.build(
	local_part: 'admin',
	is_enabled: true,
	is_admin: true,
	password_plaintext: 'admin'
)
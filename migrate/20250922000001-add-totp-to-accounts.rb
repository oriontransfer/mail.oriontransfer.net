require_relative '../config/environment'
require 'db/migrate'

migrate(VMail::Database.instance, using: DB::Migrate) do
	alter_table :accounts do
		add_column :totp_secret, "TEXT"
		add_column :totp_enabled, "BOOLEAN", default: false
	end
end
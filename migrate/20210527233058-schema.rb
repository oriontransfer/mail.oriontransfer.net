require_relative '../config/environment'
require 'db/migrate'

migrate(VMail::DATABASE, using: DB::Migrate) do
	create_table :accounts, if_not_exists: true do
		primary_key :id
		column :local_part, "TEXT", null: false
		foreign_key :domain_id, null: false
		
		column :forward, "TEXT", null: true
		column :name, "TEXT", null: false
		column :password, "TEXT", null: true
		column :mail_location, "TEXT", null: true
		column :is_enabled, "BOOLEAN", default: true, null: false
		column :is_admin, "BOOLEAN", default: false, null: false
		column :created_at, "DATETIME", null: false
		column :updated_at, "DATETIME", null: false
	end
	
	create_index "UNIQUE_EMAIL", :accounts, ["domain_id", "local_part"], if_not_exists: true, unique: true
	
	create_table :domains, if_not_exists: true do
		primary_key :id
		
		column :name, "TEXT", null: false, unique: true
		column :is_enabled, "BOOLEAN", default: true, null: false
		column :created_at, "DATETIME", null: false
		column :updated_at, "DATETIME", null: false
	end
	
	create_table :password_resets, if_not_exists: true do
		primary_key :id
		foreign_key :account_id, null: false, index: true
		
		column :token, "TEXT", null: false
		
		column :used_at, "DATETIME", null: true
		column :created_at, "DATETIME", null: false
		column :updated_at, "DATETIME", null: false
	end
end

class CreatePasswordReset < ActiveRecord::Migration[5.1]
	def change
		create_table :password_resets do |t|
			t.belongs_to :account
			t.string :token, null: false, unique: true
			
			t.boolean :used_at, null: true
			
			t.timestamps
		end
	end
end

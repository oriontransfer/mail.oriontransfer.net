class CreatePasswordReset < ActiveRecord::Migration[5.1]
	def change
		create_table :password_resets, options: "CHARSET=utf8mb4" do |t|
			t.belongs_to :account
			t.string :token, null: false, unique: true
			
			t.datetime :used_at, null: true
			
			t.timestamps
		end
	end
end

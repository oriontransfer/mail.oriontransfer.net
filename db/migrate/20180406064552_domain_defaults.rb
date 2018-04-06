class DomainDefaults < ActiveRecord::Migration[5.1]
	def change
		change_column_default(:domains, :is_enabled, true)
	end
end

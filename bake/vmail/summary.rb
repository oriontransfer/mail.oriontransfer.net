
def summary
	require 'console/terminal'
	call('environment')
	
	terminal = self.terminal
	
	VMail.schema do |schema|
		schema.domains.to_a.each do |domain|
			domain_style = domain.is_enabled ? :enabled : :disabled
			
			terminal.print_line(
				"[#{domain.id}]", domain_style, domain.name, :reset,
				"(#{domain.accounts.count} accounts): #{domain.disk_usage_string}"
			)
			
			domain.accounts.each do |account|
				account_style = account.is_enabled ? :enabled : :disabled
				account_style = :forward if account.forward
				
				terminal.print_line(
					"[#{account.id}] \t", account_style, account.description, :reset,
					": #{account.disk_usage_string}"
				)
			end
		end
	end
end

private

def terminal(out = $stdout)
	terminal = Console::Terminal.for(out)
	
	terminal[:enabled] = terminal.style(:green)
	terminal[:disabled] = terminal.style(:red)
	terminal[:forward] = terminal.style(:blue)
	
	return terminal
end
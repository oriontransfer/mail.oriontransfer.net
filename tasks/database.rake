
require 'active_record'

namespace :db do
	task :environment => :environment do
		database_tasks = ActiveRecord::Tasks::DatabaseTasks
		
		db_dir = File.expand_path('../db', __dir__)
		
		database_tasks.env = RACK_ENV
		database_tasks.db_dir = db_dir
		database_tasks.database_configuration = ActiveRecord::Base.configurations
		database_tasks.migrations_paths = File.join(db_dir, 'migrate')

		#ActiveRecord::Base.configurations = DatabaseTasks.database_configuration
		#ActiveRecord::Base.establish_connection DatabaseTasks.env
	end
end

load 'active_record/railties/databases.rake'

task :deploy => :environment do
	if ActiveRecord::Base.connection.data_sources.empty?
		Rake::Task['db:setup'].invoke
	else
		Rake::Task['db:migrate'].invoke
	end
end

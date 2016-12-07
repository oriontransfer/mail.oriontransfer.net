
require 'active_record'

task :environment do
	database_tasks = ActiveRecord::Tasks::DatabaseTasks
	
	db_dir = File.expand_path('../db', __FILE__)
	config_dir = File.expand_path('../config', __FILE__)
	
	database_tasks.env = RACK_ENV
	database_tasks.db_dir = db_dir
	database_tasks.database_configuration = YAML.load(File.read(File.join(config_dir, 'database.yml')))
	database_tasks.migrations_paths = File.join(db_dir, 'migrate')

	#ActiveRecord::Base.configurations = DatabaseTasks.database_configuration
	#ActiveRecord::Base.establish_connection DatabaseTasks.env
end

load 'active_record/railties/databases.rake'

task :deploy => :environment do
	if ActiveRecord::Base.connection.tables.empty?
		Rake::Tasks['db:setup'].invoke
	else
		Rake::Tasks['db:migrate'].invoke
	end
end

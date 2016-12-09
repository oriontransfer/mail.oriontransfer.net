
require 'active_record/migrations/tasks'
ActiveRecord::Migrations.root = File.dirname(__dir__)

task :deploy => 'db:deploy'

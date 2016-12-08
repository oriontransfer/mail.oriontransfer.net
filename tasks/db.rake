
require 'active_record/migrations'
ActiveRecord::Migrations.root = File.expand_path("../db", __dir__)

task :deploy => 'db:deploy'

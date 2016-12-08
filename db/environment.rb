
DATABASE_ENV = (ENV['DATABASE_ENV'] || RACK_ENV || :development).to_sym

ActiveRecord::Base.configurations = YAML::load_file(File.join(__dir__, "database.yml"))

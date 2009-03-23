begin
  require 'spec'
  require 'active_record'
rescue LoadError
  require 'rubygems'
  gem 'rspec'
  require 'spec'
end
require 'active_record'
$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'money'

config = YAML.load_file(File.dirname(__FILE__) + '/db/database.yml')
ActiveRecord::Base.logger = Logger.new("/tmp/money-debug.log")
ActiveRecord::Base.establish_connection(config)

db_file = File.exists?(File.dirname(__FILE__) + '/../tmp/acts_as_money.sqlite3')
load(File.dirname(__FILE__) + "/db/schema.rb") unless db_file


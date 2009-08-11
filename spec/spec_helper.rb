begin
  require 'rubygems'
  require 'spec'
  require 'active_record'
rescue LoadError
  require 'rubygems'
  gem 'rspec'
  require 'spec'
end
$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'money'

config = YAML.load_file(File.dirname(__FILE__) + '/db/database.yml')
ActiveRecord::Base.logger = Logger.new("/tmp/money-debug.log")
ActiveRecord::Base.establish_connection(config)

unless File.exists?(File.dirname(__FILE__) + '/../tmp/acts_as_money.sqlite3')
  load(File.dirname(__FILE__) + "/db/schema.rb")
end


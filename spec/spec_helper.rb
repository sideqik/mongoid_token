$: << File.expand_path("../../lib", __FILE__)

require 'database_cleaner/mongoid'
require 'mongoid'
require 'mongoid-rspec'
require 'mongoid_token'

ENV['MONGOID_ENV'] = "test"

RSpec.configure do |config|
  Mongo::Logger.logger.level = Logger::ERROR

  config.include Mongoid::Matchers
  config.before(:suite) do
    DatabaseCleaner.strategy = :deletion
  end

  config.after(:each) do
    DatabaseCleaner.clean
    Mongoid.purge!
  end
end

Mongoid.configure do |config|
  config.connect_to("mongoid_token_test", {})
end

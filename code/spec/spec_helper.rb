require File.dirname(__FILE__) + '/../app'
require 'rspec'
require 'rack/test'
require 'mongoid'
require 'database_cleaner'

set :environment, :test

RSpec.configure do |conf|
  conf.color= true
  conf.tty = true
  conf.include Rack::Test::Methods

  conf.before(:suite) do
    DatabaseCleaner[:mongoid].strategy = :truncation
    DatabaseCleaner[:mongoid].clean_with(:truncation)
  end

  conf.before(:each) do
    DatabaseCleaner[:mongoid].start
  end

  conf.after(:each) do
    DatabaseCleaner[:mongoid].clean
  end
end

def app
  App
end
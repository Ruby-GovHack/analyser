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
    Mongoid.load!("./config/mongoid.yml", :test)

    DatabaseCleaner[:mongoid].strategy = :truncation
    DatabaseCleaner[:mongoid].clean_with(:truncation)
    Seeds.new.seed_test
  end

 end

def app
  App
end
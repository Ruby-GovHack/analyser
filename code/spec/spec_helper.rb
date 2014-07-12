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
    Mongoid.load!("./config/mongoid.yml", :developer)

    #DatabaseCleaner[:mongoid].strategy = :truncation
    #DatabaseCleaner[:mongoid].clean_with(:truncation)
    #require_relative '../db/test_seeds'
  end

 end

def app
  App
end
require 'sinatra'
require 'json'
require 'sinatra/reloader' if development?
require 'mongoid'
require 'haml'
require 'redcarpet'
require_relative 'models/example_model'

class App < Sinatra::Application

  configure do
    Mongoid.load!("./config/mongoid.yml")
  end

  get '/' do
    readme = File.read("#{File.dirname(__FILE__)}/README.md")
    markdown readme, fenced_code_blocks: true, autolink: true
  end

  get '/acorn-sat/v1/sites' do
    '[
        {"id": "069018", "site": "Moruya Heads", "lat": -35.909, "long": 150.153 },
        {"id": "070351", "site": "Canberra", "lat": -35.309, "long": 149.2 },
        {"id": "072150", "site": "Wagga Wagga", "lat": -35.158, "long": 147.457 },
        {"id": "072161", "site": "Cabramurra", "lat": -35.937, "long": 148.378 }
    ]'
  end

  get '/examples' do
    content_type :json
    ExampleModel.all.to_json
  end

end

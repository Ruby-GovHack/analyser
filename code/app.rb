require 'sinatra'
require 'json'
require 'sinatra/reloader' if development?
require 'mongoid'
require 'haml'
require 'redcarpet'
require_relative 'models/example_model'
require_relative 'models/site'

class App < Sinatra::Application

  configure do
    Mongoid.load!("./config/mongoid.yml")
  end

  get '/' do
    readme = File.read("#{File.dirname(__FILE__)}/README.md")
    markdown readme, fenced_code_blocks: true, autolink: true
  end

  get '/acorn-sat/v1/sites' do
    cors_headers

    Site.fetch.to_json
  end

  get '/monthly/acorn-sat/v1/max-temp' do
    cors_headers

    '[
        {"id": "069018", "max":20.02, "std-dev": 5.11 },
        {"id": "070351", "max":18.48, "std-dev": 3.95 },
        {"id": "072150", "max":20.32, "std-dev": 3.95 },
        {"id": "072161", "max":9.61, "std-dev": 3.62 }
    ]'
  end

  get '/examples' do
    content_type :json
    ExampleModel.all.to_json
  end

  # FIXME replace with rack-cors
  def cors_headers
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'POST, PUT, DELETE, GET, OPTIONS'
    headers['Access-Control-Request-Method'] = '*'
    headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'
  end

end

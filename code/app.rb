require 'sinatra'
require 'json'
require 'sinatra/reloader' if development?
require 'mongoid'
require 'haml'
require 'redcarpet'
require_relative 'models/site'

class App < Sinatra::Application

  configure do
    Mongoid.load!("./config/mongoid.yml")
  end

  get '/' do
    readme = File.read("#{File.dirname(__FILE__)}/README.md")
    markdown readme, fenced_code_blocks: true, autolink: true
  end

  get '/v1/sites/acorn-sat' do
    cors_headers

    Site.fetch.to_json
  end

  get '/v1/timeseries/monthly/acorn-sat' do
    cors_headers

    return data_by_site(params[:site]) if params[:site]
    return data_by_bounding_box(params[:north], params[:east], params[:south], params[:west]) if params[:north]
    data_for_all_locations
  end

  def data_by_site(site)
    '[
      {"month":"09-2008", "max-temp":32.83},
      {"month":"10-2008", "max-temp":18.32},
      {"month":"11-2008", "max-temp":25.34},
      {"month":"12-2008", "max-temp":32.12},
      {"month":"01-2009", "max-temp":30.45},
      {"month":"02-2009", "max-temp":29.34},
      {"month":"03-2009", "max-temp":32.83}
    ]'
  end

  def data_by_bounding_box(north, east, south, west)
    '[
        {"id": "069018", "max-temp":20.02, "max-temp-std-dev": 5.11 },
        {"id": "070351", "max-temp":18.48, "max-temp-std-dev": 3.95 },
        {"id": "072150", "max-temp":20.32, "max-temp-std-dev": 3.95 },
        {"id": "072161", "max-temp":9.61, "max-temp-std-dev": 3.62 }
    ]'
  end

  def data_for_all_locations()

  end

  # FIXME replace with rack-cors
  def cors_headers
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'POST, PUT, DELETE, GET, OPTIONS'
    headers['Access-Control-Request-Method'] = '*'
    headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'
  end

end

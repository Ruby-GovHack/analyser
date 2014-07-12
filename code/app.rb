require 'sinatra'
require 'json'
require 'sinatra/reloader' if development?
require 'mongoid'
require 'haml'
require 'redcarpet'
require_relative 'models/site'
require_relative 'models/monthly_data'
require_relative 'models/data_provider'

class App < Sinatra::Application

  ACORN_SAT_ENDPOINT = 'http://lab.environment.data.gov.au/sparql'
  SITE_URI = 'http://lab.environment.data.gov.au/def/acorn/site/Site'
  SUPPORTED_DATASETS = ['acorn-sat']

  configure do
    Mongoid.load!("./config/mongoid.yml")
  end

  get '/' do
    readme = File.read("#{File.dirname(__FILE__)}/README.md")
    markdown readme, fenced_code_blocks: true, autolink: true
  end

  get '/v1/sites/:dataset' do
    cors_headers
    provider = DataProvider.new(provider_details(params[:dataset]))
    Site.fetch(provider).to_json
  end

  get '/v1/timeseries/monthly/:dataset' do
    cors_headers

    return data_by_site(params[:site]) if params[:site]
    return data_by_bounding_box(params[:north], params[:east], params[:south], params[:west]) if params[:north]
    data_for_all_locations
  end

  def data_by_site(site)
    provider = DataProvider.new(provider_details(params[:dataset]))
    MonthlyData.fetch(provider, site).to_json
  end

  def provider_details(dataset)
    throw("Unknown dataset: #{dataset}. Supported datasets are #{SUPPORTED_DATASETS}") unless SUPPORTED_DATASETS.include? dataset
    case dataset
      when 'acorn-sat'
        {endpoint: ACORN_SAT_ENDPOINT, site_uri: SITE_URI}
    end
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

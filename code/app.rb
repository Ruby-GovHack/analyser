require 'sinatra'
require 'json'
require 'sinatra/reloader' if development?
require 'mongoid'
require 'haml'
require 'redcarpet'
require_relative 'models/site'
require_relative 'models/monthly_data'
require_relative 'models/sparql_data_provider'

class App < Sinatra::Application

  configure do
    Mongoid.load!("./config/mongoid.yml")
  end

  get '/' do
    readme = File.read("#{File.dirname(__FILE__)}/README.md")
    markdown readme, fenced_code_blocks: true, autolink: true
  end

  get '/v1/sites/:dataset' do
    cors_headers
    SparqlDataProvider.validate_dataset(params[:dataset])
    Site.all_as_hash.to_json
  end

  def get_start
    return params[:time] if params[:time]
    params[:start]
  end

  def get_end
    return params[:time] if params[:time]
    params[:end]
  end

  get '/v1/timeseries/monthly/:dataset' do
    cors_headers

    return data_by_site(params[:site], get_start, get_end) if params[:site]
    return data_by_bounding_box(params[:north], params[:east], params[:south], params[:west], get_start, get_end) if params[:north]
    data_for_all_locations
  end

  def data_by_site(site, start_time, end_time)
    provider = SparqlDataProvider.new(params[:dataset])
    MonthlyData.fetch(provider, site, start_time, end_time).to_json
  end

  def data_by_bounding_box(north, east, south, west, start_time, end_time)
    provider = SparqlDataProvider.new(params[:dataset])
    sites = Site.all.select {|s| s.in_bounding_box(north, east, south, west)}
    result = {}
    sites.each {|site,_| result[site.site_id] = MonthlyData.fetch(provider, site.site_id, start_time, end_time)}
    result.to_json
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

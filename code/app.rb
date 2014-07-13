require 'sinatra'
require 'json'
require 'sinatra/reloader' if development?
require 'mongoid'
require 'haml'
require 'redcarpet'
require_relative 'models/site'
require_relative 'models/monthly_data'
require_relative 'models/sparql_data_provider'
require_relative 'db/seeds'

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

  get '/debug' do
    MonthlyData.count.to_s
  end

  post '/seed' do
    Seeds.new.seed_all
  end

  post '/reseed' do
    seeder = Seeds.new
    seeder.drop
    seeder.seed_all
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
    start_time = get_start
    end_time = get_end
    return data_by_site(params[:site], start_time, end_time) if params[:site]
    return data_by_bounding_box(params[:north], params[:east], params[:south], params[:west], start_time, end_time) if params[:north]
    data_for_all_locations(start_time, end_time)
  end

  def data_by_site(site_id, start_time, end_time)
    site = Site.all_as_hash[site_id]
    MonthlyData.filter_all(site, start_time, end_time).as_json(options = {:vars => params.keys}).reduce(Hash.new, :merge).to_json
  end

  def data_by_bounding_box(north, east, south, west, start_time, end_time)
    sites = Site.all.select {|s| s.in_bounding_box(north, east, south, west)}
    result = []
    sites.each {|site,_| result <<
        {site.site_id =>
             MonthlyData.filter_all(site, start_time, end_time).as_json(options = {:vars => params.keys}).reduce(Hash.new, :merge)}}
    result.reduce(Hash.new, :merge).to_json
  end

  def data_for_all_locations(start_time, end_time)
    result = []
    Site.all.each {|site,_| result <<
        {site.site_id =>
             MonthlyData.filter_all(site, start_time, end_time).as_json(options = {:vars => params.keys}).reduce(Hash.new, :merge)}}
    result.reduce(Hash.new, :merge).to_json
    #MonthlyData.filter_all_by_date(start_time, end_time).to_json(options = {:vars=>params.keys})
  end

  # FIXME replace with rack-cors
  def cors_headers
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'POST, PUT, DELETE, GET, OPTIONS'
    headers['Access-Control-Request-Method'] = '*'
    headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'
  end

end

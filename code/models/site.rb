require 'rdf'
require 'linkeddata'
require 'sparql/client'
require 'json'

class Site
  include Mongoid::Document

  field :site_id, type: String
  field :label, type: String
  field :lat, type: Float
  field :long, type: Float

  def self.create_from_solution!(solution)
    Site.create!(
        site_id: id_from_uri(solution[:site]),
        label: label_from_variable(solution[:label]),
        lat: solution[:lat].value.to_f,
        long: solution[:long].value.to_f)
  end

  def self.label_from_variable(label_variable)
    label_variable.to_s.gsub(/\w+/) do |word|
      word.capitalize
    end
  end

  def self.id_from_uri(site_uri)
    site_uri.to_s.split('/').last
  end

  def self.fetch(provider)
    lat_uri = RDF::URI('http://www.w3.org/2003/01/geo/wgs84_pos#lat')
    long_uri = RDF::URI('http://www.w3.org/2003/01/geo/wgs84_pos#long')
    label_uri = RDF::URI('http://www.w3.org/2000/01/rdf-schema#label')
    patterns = [
        [:site, 'a', provider.site_uri],
        [:site, lat_uri, :lat],
        [:site, long_uri, :long],
        [:site, label_uri, :label]
    ]
    results = provider.fetch([:site, :lat, :long, :label], patterns)

    sites = {}
    results.each do |solution|
      sites[id_from_uri(solution[:site])] = Site.create_from_solution!(solution)
    end
    sites
  end

  def as_json(options={})
    {:label => label, :lat => lat, :long => long}
  end

  def fetch_monthly_maximums(provider)
    time_series = 'http://lab.environment.data.gov.au/def/acorn/time-series/'
    acorn_sat   = 'http://lab.environment.data.gov.au/def/acorn/sat/'

    max_temp = RDF::URI(time_series + 'maxTemperatureMax')
    station  = RDF::URI('http://lab.environment.data.gov.au/data/acorn/climate/slice/station/' + site_id)
    subslice = RDF::URI('http://purl.org/linked-data/cube#subSlice')
    acorn_year  = RDF::URI(acorn_sat + 'year')
    acorn_month = RDF::URI(acorn_sat + 'month')

    vars = [:max, :year, :month]
    patterns = [
        [station,    subslice,   :sliceyear],
        [:sliceyear, subslice,   :yearmonth],
        [:yearmonth, acorn_year, :year],
        [:yearmonth, acorn_month,:month],
        [:yearmonth, max_temp,   :max]
    ]

    results = provider.fetch(vars, patterns)

    temps = {}
    results.each do |solution|
      temps[Site.id_from_uri(solution[:year]) + Site.id_from_uri(solution[:month])] = solution[:max].to_i
    end
    temps
  end

end
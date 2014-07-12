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

  def self.all_as_hash
    sites = {}
    Site.all.each do |site|
      sites[site.site_id] = site
    end
    sites
  end

  def as_json(options={})
    {:label => label, :lat => lat, :long => long}
  end

  def in_bounding_box(north, east, south, west)
    north, east, south, west = [north, east, south, west].map {|a| a.to_f}
    (lat <= north) && (lat >= south) && (long >= west) && (long <= east)
  end

end